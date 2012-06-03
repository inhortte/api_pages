class ApiPagesController < ApplicationController
  respond_to :json, :xml
  before_filter do |controller|
    request.format = "json" unless params[:format]
  end

  # Responds with json/xml of every page in the database
  # first sorted by :published_on backwards and then :created_at backwards
  # which will effectively put all unpublished pages at
  # the end.
  #
  # == Example
  #   curl http://localhost:3000/api_pages
  def index
    respond_with Page.sort(:published_on.desc, :created_at.desc)
  end

  # Creates a new page from either query parameters or json.
  # Responds with the page or errors.
  #
  # == Examples
  #   curl -X POST http://localhost:3000/api_pages -d 'title=Lutreola&content=A+Mink'
  #   curl -X POST http://localhost:3000/api_pages -d 'json={"title":"Lutreola","content":"A Mink"}'
  def create
    json = begin JSON.parse(params[:json]) rescue nil end
    ps = Page.param_keys.inject({}) do |m, k|
      m.merge!(k => (json.blank? ? params[k] : json[k]))
    end
    page = Page.new(ps)
    status = if page.save
               page
             else
               {:errors => page.errors.full_messages}
             end
    respond_with status, :location => nil
  end

  # Responds with json/xml of a page given an id.
  #
  # == Example
  #   curl http://localhost:3000/api_pages/4fcbf5608decb673a4000005
  def show
    respond_with Page.find_by_id(params[:id])
  end

  # Updates a page from query parameters or json given an id.
  # The response is meaningless.
  #
  # == Examples
  #   curl -X PUT http://localhost:3000/api_pages/4fcbf5608decb673a4000005 -d 'content=Native+to+Estonia'
  #   curl -X PUT http://localhost:3000/api_pages/4fcbf5608decb673a4000005 -d 'json={"content":"Native to Estonia."}'
  def update
    json = begin JSON.parse(params[:json]) rescue nil end
    ps = Page.param_keys.inject({}) do |m, k|
      if json.blank?
        params[k] ? m.merge!(k.to_s => params[k]) : m
      else
        json[k] ? m.merge!(k.to_s => json[k]) : m
      end
    end
    page = Page.find_by_id(params[:id])
    page.update_attributes(ps)
    respond_with "updated"
  end

  # Removes a page from the database given an id.
  #
  # == Example
  #   curl -X DELETE localhost:3000/api_pages/4fcbf5608decb673a4000005
  def destroy
    begin
      Page.destroy(params[:id])
      respond_with "destroyed"
    rescue
      respond_with({:errors => ["not destroyed"]})
    end
  end

  def new
    respond_with({:errors => ["not supported"]})
  end

  def edit
    respond_with({:errors => ["not supported"]})
  end

  # Responds with json/xml of all pages in the system who have :published_on
  # set to a time before now, sorted by :published_on backwards.
  #
  # == Example
  #   curl http://localhost:3000/api_pages/published
  def published
    respond_with published_query(true)
  end

  # Responds with json/xml of all pages in the system who have :published_on
  # set to a time after now, nil, or non-extant.
  #
  # == Example
  #   curl http://localhost:3000/api_pages/unpublished
  def unpublished
    respond_with(published_query(false) + Page.where(:published_on.exists => false).all)
  end

  # Sets the :published_on of a page to the current time.
  #
  # == Example
  #   curl http://localhost:3000/api_pages/4fcbf5608decb673a4000005/publish
  def publish
    p = Page.find_by_id(params[:id])
    p.published_on = Time.now
    p.save!
    respond_with p, :location => nil
  end

  # Responds with json/xml with the key "count" tagging the number of
  # words in a page (title + content).
  #
  # == Example
  #   curl http://localhost:3000/api_pages/4fcbf5608decb673a4000005/total_words
  def total_words
    p = Page.find_by_id(params[:id])
    c = {:count =>
      p.title.split(%r{\s+}).count + p.content.split(%r{\s+}).count}
    respond_with c
  end

  private
  def published_query(published)
    Page.where(:published_on.exists => true,
               :published_on.send(published ? "lt" : "gt") => Time.now).sort(:published_on.desc).all
  end
end
