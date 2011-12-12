# Meta Migration

Written by stakr GbR (Jan Sebastian Siwy, Martin Spickermann, Henning Staib GbR; http://www.stakr.de/)

Source: https://github.com/stakr/meta_migration

A plugin to convert database migrations from serials to timestamps.


## Usage

Invoke

    rake db:meta:rename

to rename the migration files (using 'svn mv') and store the renamings in 'db/migrate/renamings.yml'.

Then invoke

    rake db:meta:update

for each database (i.e. each developer and production) to update the 'schema_migrations' table according to the 'db/migrate/renamings.yml'.


Copyright (c) 2009 stakr GbR (Jan Sebastian Siwy, Martin Spickermann, Henning Staib GbR), released under the MIT license
