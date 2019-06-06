class Guides::Database::DatabaseSetup < GuideAction
  guide_route "/database/database-setup"

  def self.title
    "Database Setup"
  end

  def markdown
    <<-MD
    ## Configure

    Maybe a mention of which version of postgres needs to be installed or min version?

    Mention `config/database.cr` and how to configure connection and Avram configure options

    > Note about CLI tools for postgres app on macOS.

    ### Test setup

    Notes about using .env so test DB doesn't conflict with dev DB

    ## Create or Drop

    How to run create task

    How to run drop task

    ## Seeding Database

    Explain differences in seeding tasks

    Give examples on what would go in the seeding tasks

    How to run seeds

    > Note about ./script/setup running seeds, and seeding in production
    MD
  end
end
