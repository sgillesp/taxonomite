require_dependency "application_controller"
require 'mongoid'
require 'taxonomite/node'
include Taxonomite

class TaxonomiteController < ApplicationController

    def index
        @nodes = Node.all
    end

    def new
        @node = Node.new
    end

    def destroy
        poop
        @node = Node.find(params)
        poop
        if @node != nil
            @node.delete
            flash[:message] = "Deleted #{@node.name}"
            redirect_to :action => :index
        else
            redirect_to :action => :edit, :id => params[:id], :error => "Unable to find node #{:id}"
        end
    end

    def create
        @node = Node.new(node_params)
        if @node.save
            redirect_to :action => 'show', :id => @node.id, :notice => "Created #{@node.name}"
        else
            render 'new'
        end
    rescue Moped::Errors::OperationFailure => err
        # check for the appropriate error message indicating a duplicate index
        if err.message =~ /11000/
            @nodes.errors.add(:node_name, "alread exists for another node")
        else
            @nodes.errors.add(:base, err.message)
        end

        render 'new'
    end

    def show
        # must have a valid :id to show that
        if params[:id] == nil
            flash[:message] = "No such node in database"
            render 'index'
            return
        end

        # try to find the node, but catch if the node cannot be found
        @node = Node.find(params[:id])

    rescue ::Mongoid::Errors::DocumentNotFound => err
        flash[:error] = "No such node in database."
        render 'index'
    rescue ::Moped::Errors::OperationFailure => err
        # check for the appropriate error message indicating a duplicate index
        # if err.message =~ /name_index/
        #     @node.errors.add(:email, "already exists for another account")
        # else
        #     @node.errors.add(:base, err.message)
        # end
        flash[:message] = "Duplicate entry for node"

        render 'index'
    end

    def edit
        # try to find the node, but catch if the node cannot be found
        @node = Node.find(params[:id])

    rescue ::Mongoid::Errors::DocumentNotFound => err
        flash[:error] = "No such node in database."
        render 'index'
    rescue ::Moped::Errors::OperationFailure => err
        # check for the appropriate error message indicating a duplicate index
        # if err.message =~ /name_index/
        #     @node.errors.add(:email, "already exists for another account")
        # else
        #     @node.errors.add(:base, err.message)
        # end
        flash[:message] = "Duplicate entry for node"

        render 'index'
    end

    def update
        # try to find the node, but catch if the node cannot be found
        @node = Node.find(params[:id])
        if @node.update_attributes(node_params)
            if @node.save
                redirect_to :action => 'show', :id => @node.id, :notice => "Created #{@node.name}"
            else
                redirect_to(:action => 'show', :id => @node.id, :error => "Utter failure".red)
            end
        else
            puts "BAD NEWS".red.bold
            render 'edit'
        end

    rescue ::Mongoid::Errors::DocumentNotFound => err
        flash[:error] = "No such node in database."
        render 'edit'
    rescue ::Moped::Errors::OperationFailure => err
        # check for the appropriate error message indicating a duplicate index
        # if err.message =~ /name_index/
        #     @node.errors.add(:email, "already exists for another account")
        # else
        #     @node.errors.add(:base, err.message)
        # end
        flash[:message] = "Duplicate entry for node"

        render 'edit'
    end

    def addchild
        @node = Node.find(params[:id])
        if @node
            child = Node.find(params[:node])
            if child
                if do_addchild(child)
                    if @node.save()
                        flash[:message] = "#{child.name} added to #{@node.name}"
                    else
                        flash[:error] = "unable to save #{@node.name}, after attempted addition of child #{child.name}"
                    end
                else
                    flash[:error] = "unable to add #{child.name} to #{@node.name}"
                end
            else
                flash[:error] = "could not find child #{:node.id}"
            end
        else
            flash[:error] = "could not find node, corresponding to #{:id}"
        end
        # ?? no need to redirect, right? - fall back to page (i.e. edit)

        render 'edit'

    # this should not happen if raise_not_found_error = false in mongoid.yml
    rescue ::Mongoid::Errors::DocumentNotFound => err
            flash[:error] = "No such node in database."
            render 'edit'
    end

    def remchild
        @node = Node.find(params[:id])
        if @node
            child = Node.find(params[:node])
            if child
                if do_remchild(child)
                # !! deprecated if @node.remove_child(child)
                    if @node.save()
                        flash[:message] = "#{child.name} removed from #{@node.name}"
                    else
                        flash[:error] = "unable to save #{@node.name}, after attempted removal of child #{child.name}"
                    end
                else
                    flash[:error] = "unable to remove #{child.name} from #{@node.name}"
                end
            else
                flash[:error] = "could not find child #{:node.id} in #{@node.name}"
            end
        else
            flash[:error] = "could not find node, corresponding to #{:id}"
        end
        # ?? no need to redirect, right? - fall back to page (i.e. edit)

        render 'edit'

        # this should not happen if raise_not_found_error = false in mongoid.yml
    rescue ::Mongoid::Errors::DocumentNotFound => err
            flash[:error] = "No such node in database."
            render 'edit'
    end

    def breakparent
        @node = Node.find(params[:id])
        if @node
            # this could be made more complex so as to avoid specifying whether there is or
            # is not a single parent (not enforcing tree structure in the controller)
            do_remparent
        else
            flash[:error] = "could not find node, corresponding to #{:id}"
        end

        render 'edit'

    rescue ::Mongoid::Errors::DocumentNotFound => err
        flash[:error] = "No such node in database."
        render 'edit'
    end

    private
        # actual method is hidden to keep hidden
        def do_addchild(ch)
             @node.add_child(ch)
        end

        def do_remchild(ch)
             @node.remove_child(ch)
        end

        def do_remparent
            @node.remove_parent
        end

        def node_params
            params.require(:taxonomite_node).permit(:name, :description)
        end

        def add_params
            params.require(:node)
            params.permit(:addid)
        end

        def rem_params
            params.require(:node)
            params.permit(:remid)
        end
end
