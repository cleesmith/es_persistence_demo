class HomeController < ApplicationController
  before_action :authenticate_user!

  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound do
    render file: "public/404.html", status: 404, layout: false
  end

  def index
  end
end
