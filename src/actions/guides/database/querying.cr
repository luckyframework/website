class Guides::Database::Querying < GuideAction
  guide_route "/database/querying"

  def self.title
    "Querying the Database"
  end

  def markdown
    <<-MD
    ## Query Objects
    
    How Lucky uses these instead of query on the model directly. The structure of these and where they go in the app. Type safety 

    Explain available instance methods like `first`, `first?`, `find`, and `Enumberable(T)`.

    Default columns defined in model plus `id`, `created_at`, `updated_at`.

    Chainable methods

    ## Running Queries

    * first
    * find
    * each

    ## Simple Selects

    ### Select all

    ### Select one

    ### Select count

    ### Select distinct on

    ## Where clauses

    Some where query examples.

    ### A = B

    ### A != B

    ### A gt/lt B

    ### A in / not in (B)

    ### A like / iLike B

    ## Ordering

    ASC / DESC methods

    ## Pagination

    ### Limit

    ### Offset

    ## Associations and Joins

    ### Preloading

    ### Without Preloading

    ### Joins

    * join_
    * inner_join
    * left_join

    ## No results

    Explain `none`

    ## Scopes

    Examples of custom methods and chained calls

    ## Delete Record

    `delete` is actually a model method, but you get the model instance from Query, so might as well put info here.

    MD
  end
end
