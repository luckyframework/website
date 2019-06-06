class Guides::Database::Migrations < GuideAction
  guide_route "/database/migrations"

  def self.title
    "Migrations"
  end

  def markdown
    <<-MD
    ## Migration

    ### Introduction

    What a migration is, and the parts to a migration

    ### Generate a new one

    How to generate a new migration. Running the task.

    > Note that generating a Model (link to models) will generate a migration for you

    ### Anatomy

    Explain the timestamp versions, explain all migration commands. `migrate` vs `rollback` methods.

    ### DB Tasks

    * db.migrate
    * db.migrate.one
    * db.redo
    * db.rollback
    * db.rollback_all

    ## Create Table

    Explain UUID vs Int. Options for `create`. Default values, etc...

    ## Drop Table

    ## Alter Table

    ## Add Column

    Explain Types with table of how they map between Crystal and postgres.

    ## Remove Column

    ## Alter Column

    ## Add Index

    Explain different options for different types of indicies

    ## Remove Index

    ## Associations

    Explain purpose of `add_belongs_to`. Maybe an alternate way of writing it. Different options especially with UUID

    ## Custom SQL

    Using `execute` method. Show example of using custom SQL

    MD
  end
end
