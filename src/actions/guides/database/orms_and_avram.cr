class Guides::Database::ORMsAndAvram < GuideAction
  guide_route "/database/orms-and-avram"

  def self.title
    "ORMs and Avram"
  end

  def markdown
    <<-MD
    ## Avram

    A note about the name "Avram". Link to the Avram repo. Lucky decision to focus on Postgres.

    ## Parts to Avram

    * Models
    * Queries
    * Forms
    * Boxes
    * Migrations

    ## Alternate ORMs

    Lucky doesn't require any ORM to run. (example being this website).

    If an alternate ORM is required, list tips & tricks to setting something up. Nothing specific, but where to add settings, and such.
    MD
  end
end
