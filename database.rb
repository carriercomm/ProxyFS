
$LOAD_PATH.unshift File.dirname(__FILE__)

require "config/database"
require "db/migrations/create_mirrors"
require "db/migrations/create_tasks"

CreateMirrors.up
CreateTasks.up

