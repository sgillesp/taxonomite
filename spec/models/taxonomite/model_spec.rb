require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Tree, type: :model do

        context 'model function' do
            let!(:taxon) { build(:taxonomite_taxon) }

            it 'instantiates a taxon' do
                expect(taxon.class.name).to eq("Taxonomite::Taxon")
            end

            it 'destroys a taxon' do
                expect { taxon.destroy }.not_to raise_error
            end

            it 'sets the name' do
                taxon.name = "new_name"
                expect(taxon.name).to eq("new_name")
            end

            it 'sets the description' do
                taxon.description = "new_description"
                expect(taxon.description).to eq("new_description")
            end

            it 'allow access to children' do
                expect { taxon.children }.not_to raise_error
            end

            it 'allow access to parent' do
                expect { taxon.parent }.not_to raise_error
            end

        end

    end
end
