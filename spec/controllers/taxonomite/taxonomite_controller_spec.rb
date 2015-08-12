require 'rails_helper'
require 'spec_helper'
require 'taxonomite/taxon'

module Taxonomite

  RSpec.describe TaxonomiteController, type: :controller do

    #routes { Taxonomite::Engine.routes }

    before :all do
      # populate the database prior to trying index/get
      @sample = FactoryGirl.create(:taxonomite_taxon)
    end

    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    # really just test that an invalid id (=1) fails
    describe "GET #show" do
      it "returns http success" do
        get :show, :id => @sample.id
        expect(response).to have_http_status(:success)
      end
    end

  end

end
