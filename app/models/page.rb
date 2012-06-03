class Page
  include MongoMapper::Document

  key :title, String, :required => true, :unique => true
  key :content, String, :required => true
  key :published_on, Time
  timestamps!

  ensure_index(:title)

  def to_hash
    Page.keys.keys.inject({}) { |m, k| m.merge!(k => self[k]) }
  end

  class << self
    def param_keys
      Page.keys.keys.select { |k| !['created_at',
                                    'updated_at',
                                    '_id'].include?(k) }
    end
  end
end
