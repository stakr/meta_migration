namespace :db do
  
  namespace :meta do
    
    desc "Renames migrations from serials to timestamps and stores renamings in 'db/migrate/renamings.yml'"
    task :rename => :environment do
      
      # renamings
      renamings = {}
      
      # find all migrations
      last_time = nil
      Dir.glob("#{RAILS_ROOT}/db/migrate/*.rb").each do |file|
        next unless File.basename(file, '.rb') =~ /(\d{3})_(.*)/
        
        # migration number and class name (underscore)
        number     = $1.to_i
        class_name = $2
        
        # timestamp
        time = `svn log #{file}`                # complete log
        time = time.split('-' * 72 + $/)[-1]    # initial commit
        time = time.split($/)[0]                # first line of initial commit
        time = time.split(' | ')[2][0..19]      # creation time as ugly string
        time = Time.parse(time)                 # creation time as time object
        if last_time && time <= last_time       # preserve order of migrations
          time = last_time + 1.second
        end
        last_time = time
        time = time.strftime("%Y%m%d%H%M%S")    # creation time as migration timestamp
        
        # add renaming
        renamings[number] = time
        
        # rename migration (and its auxiliary directory, if necessary)
        file_dest = File.join(File.dirname(file), "#{time}_#{class_name}.rb")
        `svn mv #{file} #{file_dest}`
        aux = File.join(File.dirname(file), File.basename(file, '.rb'))
        if File.exist?(aux)
          aux_dest = File.join(File.dirname(file), "#{time}_#{class_name}")
          `svn mv #{aux} #{aux_dest}`
        end
        
      end
      
      # store renamings
      File.open("#{RAILS_ROOT}/db/migrate/renamings.yml", 'w') do |f|
        f << renamings.to_yaml
      end
      
    end
    
    desc "Updates 'schema_migrations' table according to 'db/migrate/renamings.yml' from db:meta:rename"
    task :update => :environment do
      
      # read renamings
      renamings = YAML.load(File.read("#{RAILS_ROOT}/db/migrate/renamings.yml"))
      
      # update schema_migrations
      renamings.each do |now, after|
        ActiveRecord::Base.connection.execute "UPDATE schema_migrations SET version = #{ActiveRecord::Base.connection.quote(after)} WHERE version = #{ActiveRecord::Base.connection.quote(now.to_s)}"
      end
      
    end
    
  end
  
end
