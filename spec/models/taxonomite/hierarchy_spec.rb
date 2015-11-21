require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Tree, type: :model do
        describe 'enforce hierarchy' do
            context 'without Taxonomy object' do
                before(:each) do
                    @family = FactoryGirl.build(:taxonomite_family)
                    @genus = FactoryGirl.build(:taxonomite_genus)
                    @species = FactoryGirl.build(:taxonomite_species)
                end

                it 'to allow species in genus when no taxonomy present' do
                    expect { @genus.add_child(@species) }.not_to raise_error
                end

                it 'to allow genus in family when no taxonomy present' do
                    expect { @family.add_child(@genus) }.not_to raise_error
                end

                it 'to allow genus in species when no taxonomy present' do
                    expect { @species.add_child(@genus) }.not_to raise_error
                end

                it 'to allow species in family when no taxonomy present' do
                    expect { @family.add_child(@species) }.not_to raise_error
                end
            end

            context 'taxonomy with multiple possibilities' do
              before(:each) do
                @taxonomy = FactoryGirl.build(:single_taxonomy_with_multiple)
                @kingdom = FactoryGirl.build(:taxonomite_kingdom)
                @phylum = FactoryGirl.build(:taxonomite_phylum)
                @class = FactoryGirl.build(:taxonomite_class)
                @species = FactoryGirl.build(:taxonomite_species)
              end

              it 'to allow appropriate in kingdom (under [ phylum, class, order] )' do
                expect { @taxonomy.add(@kingdom, @phylum) }.not_to raise_error
                expect { @taxonomy.add(@kingdom, @class) }.not_to raise_error
                expect { @taxonomy.add(@kingdom, @species) }.to raise_error
              end

              it 'to disallow inappropriate relations in kingdom' do
                expect { @taxonomy.add(@kingdom, @species) }.to raise_error
                expect { @taxonomy.add(@kingdom, @kingdom) }.to raise_error
              end

            end


            context 'specific taxonomy rejections, with wildcard' do
              before(:each) do
                @taxonomy = FactoryGirl.build(:taxonomite_single_wildcard_taxonomy)
                @kingdom = FactoryGirl.build(:taxonomite_kingdom)
                @phylum = FactoryGirl.build(:taxonomite_phylum)
                @class = FactoryGirl.build(:taxonomite_class)
                @species = FactoryGirl.build(:taxonomite_species)
              end

              it 'to allow anything in kingdom (under "*")' do
                expect { @taxonomy.add(@kingdom, @phylum) }.not_to raise_error
                expect { @taxonomy.add(@kingdom, @class) }.not_to raise_error
                expect { @taxonomy.add(@kingdom, @species) }.not_to raise_error
              end

              it 'to allow only class under phylum' do
                expect { @taxonomy.add(@phylum, @class) }.not_to raise_error
                expect { @taxonomy.add(@phylum, @species) }.to raise_error
                expect { @taxonomy.add(@phylum, @kingdom) }.to raise_error
              end

              it 'to allow only nothing under class (empty)' do
                expect { @taxonomy.add(@class, @phylum) }.to raise_error
                expect { @taxonomy.add(@class, @species) }.to raise_error
                expect { @taxonomy.add(@class, @kingdom) }.to raise_error
              end
            end

            context 'empty Taxonomy object' do
              before(:each) do
                  @taxonomy = FactoryGirl.build(:taxonomite_empty_taxonomy)
                  @family = FactoryGirl.build(:taxonomite_family)
                  @genus = FactoryGirl.build(:taxonomite_genus)
                  @species = FactoryGirl.build(:taxonomite_species)
              end

              it 'to allow anything anywhere' do
                  expect { @taxonomy.add(@genus, @species) }.not_to raise_error
                  expect { @taxonomy.add(@family, @genus) }.not_to raise_error
                  expect { @taxonomy.add(@species, @genus) }.to raise_error # circular reference
                  expect { @taxonomy.add(@family, @species) }.not_to raise_error
              end
            end

            context 'with down-looking Taxonomy object' do
              before(:each) do
                  @taxonomy = FactoryGirl.build(:taxonomite_down_taxonomy)
                  @family = FactoryGirl.build(:taxonomite_family)
                  @genus = FactoryGirl.build(:taxonomite_genus)
                  @species = FactoryGirl.build(:taxonomite_species)
              end

              it 'to allow species in genus with taxonomy present' do
                  expect { @taxonomy.add(@genus, @species) }.not_to raise_error
              end

              it 'to allow genus in family with taxonomy present' do
                  expect { @taxonomy.add(@family, @genus) }.not_to raise_error
              end

              it 'not to allow genus in species with taxonomy present' do
                  expect { @taxonomy.add(@species, @genus) }.to raise_error
              end

              it 'not to allow species in family with taxonomy present' do
                  expect { @taxonomy.add(@family, @species) }.to raise_error
              end
            end

            context 'with up-looking Taxonomy object' do
              before(:each) do
                  @taxonomy = FactoryGirl.build(:taxonomite_up_taxonomy)
                  @family = FactoryGirl.build(:taxonomite_family)
                  @genus = FactoryGirl.build(:taxonomite_genus)
                  @genus2 = FactoryGirl.build(:taxonomite_genus)
                  @species = FactoryGirl.build(:taxonomite_species)
              end

              it 'to allow species in genus with taxonomy present' do
                  expect { @taxonomy.add(@genus, @species) }.not_to raise_error
              end

              it 'to allow genus in family with taxonomy present' do
                  expect { @taxonomy.add(@family, @genus) }.not_to raise_error
              end

              it 'not to allow genus in species with taxonomy present' do
                  expect { @taxonomy.add(@species, @genus) }.to raise_error
              end

              it 'not to allow species in family with taxonomy present' do
                  expect { @taxonomy.add(@family, @species) }.to raise_error
              end

            end

            context 'places taxons within the the taxonomy' do
              before (:each) do
                @taxonomy = FactoryGirl.build(:taxonomite_down_taxonomy)
                @family = FactoryGirl.build(:taxonomite_family)
                @genus = FactoryGirl.build(:taxonomite_genus)
                @genus2 = FactoryGirl.build(:taxonomite_genus)
                @species = FactoryGirl.build(:taxonomite_species)
                @taxonomy.add(@family, @genus)
                @taxonomy.add(@genus, @species)
                @taxonomy.add(@genus, FactoryGirl.build(:taxonomite_species))
                @taxonomy.add(@family, @genus2)
              end

              it 'correctly determines that a taxonomy location is valid' do
                expect(@taxonomy.is_parent(@genus, @species.hash_up)).to eq(true)
              end

              it 'correctly determines that a taxonomy location is invalid' do
                expect(@taxonomy.is_parent(@genus2, @species.hash_up)).to eq(false)
              end

              it 'correctly determines that a taxonomy location is within the same taxonomy tree' do

              end

              it 'correctly finds the appropriate parent for a particular entity, with down-looking taxonomy' do
              end

              it 'correctly finds the appropriate parent for a particular entity, with up-looking taxonomy' do
              end



            end

      end
    end
end
