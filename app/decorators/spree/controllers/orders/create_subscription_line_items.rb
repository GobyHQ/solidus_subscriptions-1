# Create new subscription line items associated to the current order, when
# a line item is added to the cart which includes subscription_line_item
# params.
#
# The Subscriptions::LineItem acts as a line item place holder for a
# Subscription, indicating that it has been added to the order, but not
# yet purchased
module Spree
  module Controllers
    module Orders
      module CreateSubscriptionLineItems
        include SolidusSubscriptions::SubscriptionLineItemBuilder

        def self.prepended(base)
          base.after_action(
            :handle_subscription_line_items,
            only: [:populate, :populate_multiple],
            if: -> { params[:subscription_line_item] }
          )
        end

        private

        # This method has been changed to accept multiple subscribable_id's
        # Required params:
        #   "subscription_line_item"=>{
        #     ...
        #     "subscribable_id"=>{"variant_id"=>"subscribable_id"}
        #     ...
        #   }
        # Example params:
        #   "subscription_line_item"=>{
        #     ...
        #     "subscribable_id"=>{"1"=>"4"}
        #     ...
        #   }
        def handle_subscription_line_items
          variant_ids = params[:subscription_line_item][:subscribable_id].keys
          line_items = @current_order.line_items.where(variant_id: variant_ids)
          line_items.each do |line_item|
            subscribable_id = params[:subscription_line_item][:subscribable_id][line_item.variant_id.to_s]
            create_subscription_line_item(line_item, subscribable_id)
          end
        end
      end
    end
  end
end

Spree::OrdersController.prepend(Spree::Controllers::Orders::CreateSubscriptionLineItems)
