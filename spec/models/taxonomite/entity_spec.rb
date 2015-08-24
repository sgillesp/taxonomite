require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Entity, type: :model do

        context 'model function' do
            let!(:being) { build(:taxonomite_beingrep) }

            it 'instantiates an entity' do
                expect(being.class.name).to eq("Taxonomite::BeingRep")
            end

            it 'destroys an entity' do
                expect { being.destroy }.not_to raise_error
            end

            it 'sets the name' do
                being.name = "new_name"
                expect(being.name).to eq("new_name")
            end

            it 'allow access to taxonomy_node' do
                expect { being.get_taxonomy_node }.not_to raise_error
            end

            it 'expects taxonomy_node to have a name' do
                expect(being.get_taxonomy_node.name).to eq(being.name)
            end

            it 'can get to the entity through the taxonomy_node' do
              expect(being.get_taxonomy_node.owner).to eq(being)
            end

        end

    end
end
