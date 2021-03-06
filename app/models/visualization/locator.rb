# encoding: utf-8
require_relative '../visualization'
require_relative './member'
require_relative '../user'
require_relative '../table'

module CartoDB
  module Visualization
    class Locator
      def initialize(user_model=nil)
        @user_model   = user_model  || ::User
      end #initialize

      def get(id_or_name, subdomain)
        user = user_from(subdomain)

        visualization_from(id_or_name, user) || 
        table_from(id_or_name, user)         ||
        [nil, nil]
      end #get

      private

      attr_reader :user_model

      def user_from(subdomain)
        @user ||= user_model.where(username: subdomain).first
      end #user_from

      def visualization_from(id_or_name, user)
        if user
          visualization = get_by_name(id_or_name, user)
        end
        unless visualization
          visualization = get_by_id(id_or_name)
        end

        return false if visualization.nil?

        [visualization, visualization.table]
      end # visualization_from

      def table_from(id_or_name, user)
        table = ::Table.get_by_id(id_or_name, user)
        return false unless table && table.table_visualization
        [table.table_visualization, table]
      rescue
        false
      end #table_from
        
      def get_by_id(uuid)
        Visualization::Collection.new.fetch(
            id: uuid
        ).first
      rescue KeyError
        nil
      end #get_by_id

      def get_by_name(name, user)
        # when looking for a visualization using name return
        # the ones that user owns. Collection returns
        Visualization::Collection.new.fetch(
            name:   name,
            user_id: user.id
        ).select { |u| u.user_id == user.id }.first
      rescue KeyError
        nil
      end #get_by_name
    end # Locator
  end # Visualization
end # CartoDB

