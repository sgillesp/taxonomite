require_dependency "application_controller"
require 'mongoid'
require 'taxonomite/taxon'
include Taxonomite

class TaxonomiteController < ApplicationController

    def index
        @taxons = Taxon.all
    end

    def new
        @taxon = Taxon.new
    end

    def destroy
        poop
        @taxon = Taxon.find(params)
        poop
        if @taxon != nil
            @taxon.delete
            flash[:message] = "Deleted #{@taxon.name}"
            redirect_to :action => :index
        else
            redirect_to :action => :edit, :id => params[:id], :error => "Unable to find taxon #{:id}"
        end
    end

    def create
        @taxon = Taxon.new(taxon_params)
        if @taxon.save
            redirect_to :action => 'show', :id => @taxon.id, :notice => "Created #{@taxon.name}"
        else
            render 'new'
        end
    rescue Moped::Errors::OperationFailure => err
        # check for the appropriate error message indicating a duplicate index
        if err.message =~ /11000/
            @taxons.errors.add(:taxon_name, "alread exists for another Taxon")
        else
            @taxons.errors.add(:base, err.message)
        end

        render 'new'
    end

    def show
        # must have a valid :id to show that
        if params[:id] == nil
            flash[:message] = "No such Taxon in database"
            render 'index'
            return
        end

        # try to find the taxon, but catch if the taxon cannot be found
        @taxon = Taxon.find(params[:id])

    rescue ::Mongoid::Errors::DocumentNotFound => err
        flash[:error] = "No such Taxon in database."
        render 'index'
    rescue ::Moped::Errors::OperationFailure => err
        # check for the appropriate error message indicating a duplicate index
        # if err.message =~ /name_index/
        #     @taxon.errors.add(:email, "already exists for another account")
        # else
        #     @taxon.errors.add(:base, err.message)
        # end
        flash[:message] = "Duplicate entry for Taxon"

        render 'index'
    end

    def edit
        # try to find the taxon, but catch if the taxon cannot be found
        @taxon = Taxon.find(params[:id])

    rescue ::Mongoid::Errors::DocumentNotFound => err
        flash[:error] = "No such Taxon in database."
        render 'index'
    rescue ::Moped::Errors::OperationFailure => err
        # check for the appropriate error message indicating a duplicate index
        # if err.message =~ /name_index/
        #     @taxon.errors.add(:email, "already exists for another account")
        # else
        #     @taxon.errors.add(:base, err.message)
        # end
        flash[:message] = "Duplicate entry for Taxon"

        render 'index'
    end

    def update
        # try to find the taxon, but catch if the taxon cannot be found
        @taxon = Taxon.find(params[:id])
        if @taxon.update_attributes(taxon_params)
            if @taxon.save
                redirect_to :action => 'show', :id => @taxon.id, :notice => "Created #{@taxon.name}"
            else
                redirect_to(:action => 'show', :id => @taxon.id, :error => "Utter failure".red)
            end
        else
            puts "BAD NEWS".red.bold
            render 'edit'
        end

    rescue ::Mongoid::Errors::DocumentNotFound => err
        flash[:error] = "No such Taxon in database."
        render 'edit'
    rescue ::Moped::Errors::OperationFailure => err
        # check for the appropriate error message indicating a duplicate index
        # if err.message =~ /name_index/
        #     @taxon.errors.add(:email, "already exists for another account")
        # else
        #     @taxon.errors.add(:base, err.message)
        # end
        flash[:message] = "Duplicate entry for Taxon"

        render 'edit'
    end

    def addchild
        @taxon = Taxon.find(params[:id])
        if @taxon
            child = Taxon.find(params[:taxon])
            if child
                if do_addchild(child)
                    if @taxon.save()
                        flash[:message] = "#{child.name} added to #{@taxon.name}"
                    else
                        flash[:error] = "unable to save #{@taxon.name}, after attempted addition of child #{child.name}"
                    end
                else
                    flash[:error] = "unable to add #{child.name} to #{@taxon.name}"
                end
            else
                flash[:error] = "could not find child #{:taxon.id}"
            end
        else
            flash[:error] = "could not find taxon, corresponding to #{:id}"
        end
        # ?? no need to redirect, right? - fall back to page (i.e. edit)

        render 'edit'

    # this should not happen if raise_not_found_error = false in mongoid.yml
    rescue ::Mongoid::Errors::DocumentNotFound => err
            flash[:error] = "No such Taxon in database."
            render 'edit'
    end

    def remchild
        @taxon = Taxon.find(params[:id])
        if @taxon
            child = Taxon.find(params[:taxon])
            if child
                if do_remchild(child)
                # !! deprecated if @taxon.remove_child(child)
                    if @taxon.save()
                        flash[:message] = "#{child.name} removed from #{@taxon.name}"
                    else
                        flash[:error] = "unable to save #{@taxon.name}, after attempted removal of child #{child.name}"
                    end
                else
                    flash[:error] = "unable to remove #{child.name} from #{@taxon.name}"
                end
            else
                flash[:error] = "could not find child #{:taxon.id} in #{@taxon.name}"
            end
        else
            flash[:error] = "could not find taxon, corresponding to #{:id}"
        end
        # ?? no need to redirect, right? - fall back to page (i.e. edit)

        render 'edit'

        # this should not happen if raise_not_found_error = false in mongoid.yml
    rescue ::Mongoid::Errors::DocumentNotFound => err
            flash[:error] = "No such Taxon in database."
            render 'edit'
    end

    def breakparent
        @taxon = Taxon.find(params[:id])
        if @taxon
            # this could be made more complex so as to avoid specifying whether there is or
            # is not a single parent (not enforcing tree structure in the controller)
            do_remparent
        else
            flash[:error] = "could not find taxon, corresponding to #{:id}"
        end

        render 'edit'

    rescue ::Mongoid::Errors::DocumentNotFound => err
        flash[:error] = "No such Taxon in database."
        render 'edit'
    end

    private
        # actual method is hidden to keep hidden
        def do_addchild(ch)
             @taxon.children << ch
        end

        def do_remchild(ch)
             @taxon.children.delete(ch)
        end

        def do_remparent
            @taxon.parent.delete(@taxon)
        end

        def taxon_params
            params.require(:taxonomite_taxon).permit(:name, :description)
        end

        def add_params
            params.require(:taxon)
            params.permit(:addid)
        end

        def rem_params
            params.require(:taxon)
            params.permit(:remid)
        end
end
