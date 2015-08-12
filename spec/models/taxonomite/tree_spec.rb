require 'spec_helper'
require 'models/taxonomite/zoology'

module Taxonomite
    RSpec.describe Taxon, type: :model do

      context 'tree creation' do
          let!(:taxons) { Array.new(3){ |index| build(:taxonomite_taxon)} }

          it 'to disallow direct circular reference' do
              # rephrase to check validity
              expect { taxons[0].children << taxons[0] }.to raise_error
          end

          it 'to disallow circular reference (one deep)' do
               taxons[0].children << taxons[1]
               expect { taxons[1].children << taxons[0] }.to raise_error
          end
      end

      context 'tree structure' do
        before(:each) do
          @taxons = Array.new(3) { build(:taxonomite_taxon) }
          @taxons[0].children << @taxons[1]
          @taxons[1].children << @taxons[2]
        end

          it 'has appropriate children' do
            expect(@taxons[0].children.size).to eq(1)
          end

          it 'to disallow circular reference (two deep)' do
              expect { @taxons[2].children << @taxons[0] }.to raise_error
          end

          it 'to iterate children' do
              @taxons[0].children.each do |p|
                  expect(p).not_to eq(nil)
              end
          end

          it 'to allow real access to parent' do
              expect(@taxons[1].parent).not_to eq(nil)
              expect { @taxons[1].parent.name }.not_to raise_error
          end

          it 'ok to destroy a parent object safely' do
              expect { @taxons[0].destroy }.not_to raise_error
              expect(@taxons[1].parent).to eq(nil)
              expect(@taxons[2].parent).not_to eq(nil)
          end

      end

    end
end
