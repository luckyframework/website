abstract class BaseSerializer
  include Lucky::Serializable

  def self.for_collection(collection : Enumerable, *args, **named_args)
    collection.map do |object|
      new(object, *args, **named_args)
    end
  end
end
