require "spec_helper"

published_one = {:title => "Martes Foina",
  :content => "A mostly urban mustelid with a white chest patch.",
  :published_on => Time.now.yesterday}
published_two = {:title => "Martes Martes",
  :content => "An arboreal mustlelid with a yellow chest patch.",
  :published_on => Time.now.months_ago(1)}
unpublished_one = {:title => "Gulo Gulo",
  :content => "An unpublished, violent mustelid."}
unpublished_two = {:title => "Mustela Altaica",
  :content => "You'll have to go to Ulaan Bataar to see this one.",
  :published_on => Time.now.tomorrow}

describe ApiPagesController do
  before(:each) do
    @foina_id = Page.create!(published_one)[:_id].to_s
    Page.create!(published_two)
    @gulo_id = Page.create!(unpublished_one)[:_id].to_s
    Page.create!(unpublished_two)
  end

  describe "GET index" do
    it "contains four pages" do
      get :index
      JSON.parse(response.body).count.should eq 4
    end
  end

  describe "POST create" do
    it "takes a new posted page and returns it" do
      post :create, :title => "Mustela Lutreola", :content => "An endangered, Estonian mustelid.", :format => "json"
      JSON.parse(response.body)["title"].should eq "Mustela Lutreola"
    end

    it "takes a new page from json and returns it" do
      post :create, :json => {:title => "Mustela Lutreola", :content => "An endangered, Estonian mustelid."}.to_json
      JSON.parse(response.body)["title"].should eq "Mustela Lutreola"      
    end

    it "stores a new posted page" do
      post :create, :title => "Mustela Lutreola", :content => "An endangered, Estonian mustelid.", :format => "json"
      get :index
      JSON.parse(response.body).map { |a| a["title"] }.should include("Mustela Lutreola")
    end
  end

  describe "GET show" do
    it "returns a page given its id" do
      get :show, :id => @foina_id
      JSON.parse(response.body)["title"].should eq "Martes Foina"
    end
  end

  describe "PUT update" do
    it "modifies a page" do
      put :update, :id => @foina_id, :content => "A mostly annoying mustelid with a white chest patch."
      get :show, :id => @foina_id
      JSON.parse(response.body)["content"].should =~ /annoying/
    end

    it "modifies a page with json" do
      put :update, :id => @foina_id, :json => {:title => "Martes Pennanti", :content => "A huger mustelid."}.to_json
      get :show, :id => @foina_id
      page = JSON.parse(response.body)
      page["title"].should =~ /Pennanti/
      page["content"].should =~ /huger/
    end
  end

  describe "DELETE destroy" do
    it "does what you expect" do
      delete :destroy, :id => @foina_id
      Page.find_by_id(@foina_id).should be_nil
    end
  end

  describe "GET published" do
    it "returns a json array of published pages" do
      get :published
      pages = JSON.parse(response.body)
      pages.count.should eq 2
      pages.map { |p| p["title"] }.should include("Martes Martes")
    end
  end

  describe "GET unpublished" do
    it "returns a json array of unpublished pages" do
      get :unpublished
      pages = JSON.parse(response.body)
      pages.count.should eq 2
      pages.map { |p| p["title"] }.should include("Gulo Gulo")
    end
  end

  describe "POST publish" do
    it "publishes a page, setting :published_on to the current time" do
      post :publish, :id => @gulo_id
      get :published
      pages = JSON.parse(response.body)
      pages.count.should eq 3
      pages.map { |p| p["title"] }.should include("Gulo Gulo")      
      get :unpublished
      JSON.parse(response.body).count.should eq 1
    end
  end

  describe "GET total_words" do
    it "calculates the total words in a page (title + content)" do
      get :total_words, :id => @foina_id
      JSON.parse(response.body)["count"].should eq 11
    end
  end
end
