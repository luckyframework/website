class Guides::Database::Models < GuideAction
  guide_route "/database/models"

  def self.title
    "Database Models"
  end

  def markdown
    <<-MD
    ## Generate a Model

    Explain gen task with options. What files are created. Each section should link to page explaining those (i.e. ModelQuery links to queries, Form links to saving, migration links to migrations page).

    Show example model generated with several different columns

    ### Defining a column

    show all options, and example of each supported type

    Default generated columns

    Nillable vs non-nillable types

    ## Model Associations

    What they are...

    > Note that adding require statements in to the model may be necessary due to how crystal require works?

    ### Belongs to

    ### Has One (one to one)

    ### Has Many (one to many)

    ### Has Many Through (many to many)

    ### Polymorphic?

    ### Using STI?
    MD
  end
end
