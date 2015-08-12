#lib/task/db_populate
require 'factory_girl'
require 'util'

namespace :db do
    namespace :pop do

        # method to create a place
        def make_taxon (ptype)
            case ptype
                when 'kingdom'
                    FactoryGirl.create(:taxonomite_kingdom)
                when 'phylum'
                    FactoryGirl.create(:taxonomite_phylum)
                when 'class'
                    FactoryGirl.create(:taxonomite_class)
                when 'order'
                    FactoryGirl.create(:taxonomite_order)
                when 'family'
                    FactoryGirl.create(:taxonomite_family)
                when 'genus'
                    FactoryGirl.create(:taxonomite_genus)
                when 'species'
                    FactoryGirl.create(:taxonomite_species)
                else
                    FactoryGirl.create(:taxonomite_taxon)
            end
        end

        # method which generates entries
        def pop_taxonomy (count, ptype = 'species')

            print "Creating #{count} "; print "#{count > 1 ? ptype.pluralize : ptype} in ".green; print "#{Rails.env}".green.bold; print " database ".green

            # include all of the factories in spec
            Dir['./spec/factories/*.rb'].each { |f| require f.to_s }

            dval = [ (count / 10), 1 ].max
            for i in 1..count
                place = make_taxon(ptype)
                if i % dval == 0
                    print('.'.green)
                end
            end
            puts " done!".green.bold
        end

        # call should be db:pop:places (is app:db:pop:places -- NEED TO FIX THAT?)
        desc 'Seed database with development place data'
        task :tax, [:type, :count] => :environment do |t, args|

            count = (args[:count] || 10).to_i

            puts
            puts "Seeding database with development taxonomy data".gray
            print "Using ".gray; print "#{Rails.env}".bold.gray; print " database.".gray
            puts

            fail "Cannot instantiate #{count} taxons! Terminating...".red.bold if count < 1

            pop_taxonomy(count,args[:type] || 'species')

        end

    end # namespace :places
end
