require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Taxon, type: :model do

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

        context 'tree structure' do
            let!(:taxons) { Array.new(3){ |index| build(:taxonomite_taxon)} }

            it 'to disallow direct circular reference' do
                # rephrase to check validity
                expect { taxons[0].children << taxons[0] }.to raise_error
            end

            it 'to disallow circular reference (one deep)' do
                 taxons[0].children << taxons[1]
                 expect { taxons[1].children << taxons[0] }.to raise_error
            end

            it 'to disallow circular reference (two deep)' do
                taxons[0].children << taxons[1]
                taxons[1].children << taxons[2]
                expect { taxons[2].children << taxons[0] }.to raise_error
            end

            it 'to allow cycle through children' do
                taxons[0].children.each do |p|
                    expect {p}.not_to eq(nil)
                end
            end

            it 'to allow real access to parent' do
                taxons[0].children << taxons[1]
                expect(taxons[1].parent).not_to eq(nil)
                expect { taxons[1].parent.name }.not_to raise_error
            end

        end

        context 'taxonomic hierarchy' do
            before(:each) do
                @family = FactoryGirl.build(:taxonomite_family)
                @genus = FactoryGirl.build(:taxonomite_genus)
                @species = FactoryGirl.build(:taxonomite_species)
            end

            it 'to allow species in genus' do
                expect { @genus.children << @species }.not_to raise_error
            end

            it 'to allow genus in family' do
                expect { @family.children << @genus }.not_to raise_error
            end

            it 'not to allow genus in species' do
                expect { @species.children << @genus }.to raise_error
            end

            it 'not to allow species in family' do
                expect { @family.children << @species }.to raise_error
            end

        end

    end

end
