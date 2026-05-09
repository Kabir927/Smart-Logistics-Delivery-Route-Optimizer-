# SLDRO - Main Application


import sys
import os

# Add ai and app folders to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'ai'))
sys.path.append(os.path.join(os.path.dirname(__file__)))

from db_connect   import fetch_pending_orders, update_order_status, save_route
from clustering   import cluster_orders
from forecasting  import forecast_demand, print_forecast
from optimizer    import optimize_all_clusters, print_optimized_routes


def print_header():
    print("=" * 55)
    print("   Smart Logistics & Delivery Route Optimizer")
    print("   SLDRO v1.0 | Developer: Kabir")
    print("=" * 55)


def print_section(title):
    print(f"\n--- {title} ---")


def run_sldro():
    """
    Main function that runs the entire SLDRO system
    """
    print_header()

    # STEP 1: Fetch pending orders from database

    print_section("STEP 1: Fetching Pending Orders")
    orders = fetch_pending_orders()

    if not orders:
        print("No pending orders found. System exiting.")
        return

    print(f"Found {len(orders)} pending orders.")
    for order in orders:
        print(f"  Order #{order['order_id']} | "
              f"{order['customer_name']} | "
              f"Priority: {order['priority']}")

    # STEP 2: Demand Forecasting

    print_section("STEP 2: Demand Forecasting")
    predictions = forecast_demand(days_ahead=7)
    print_forecast(predictions)


    # STEP 3: Cluster orders by location

    print_section("STEP 3: Clustering Orders by Location")
    orders, centers = cluster_orders(orders, n_clusters=3)
    print(f"Orders grouped into {len(centers)} delivery zones.")

    # Show cluster summary
    for cid in range(len(centers)):
        cluster = [o for o in orders if o['cluster_id'] == cid]
        print(f"  Zone {cid + 1}: {len(cluster)} orders")


    # STEP 4: Optimize routes

    print_section("STEP 4: Optimizing Delivery Routes")

    vehicles = [
        {"id": 1, "plate": "ABC-123", "type": "bike"},
        {"id": 2, "plate": "XYZ-456", "type": "van"},
        {"id": 3, "plate": "LMN-789", "type": "truck"}
    ]

    results = optimize_all_clusters(orders, centers, vehicles)
    print_optimized_routes(results)


    # STEP 5: Save routes to database

    print_section("STEP 5: Saving Routes to Database")
    for r in results:
        save_route(
            vehicle_id     = r['vehicle_id'],
            route_name     = f"Route-Cluster-{r['cluster_id'] + 1}",
            total_distance = r['total_distance'],
            estimated_time = r['estimated_time'],
            cluster_id     = r['cluster_id']
        )


    # STEP 6: Update order status to assigned

    print_section("STEP 6: Updating Order Status")
    for order in orders:
        update_order_status(order['order_id'], 'assigned')

    print(f"All {len(orders)} orders marked as assigned.")

    # STEP 7: Final Summary

    print_section("FINAL SUMMARY")
    print(f"Total orders processed : {len(orders)}")
    print(f"Total clusters created : {len(results)}")
    print(f"Total vehicles assigned: {len(vehicles)}")
    total_dist = sum(r['total_distance'] for r in results)
    print(f"Total distance         : {round(total_dist, 2)} km")
    print(f"System status          : All routes optimized")

    print("\n" + "=" * 55)
    print("   SLDRO Run Complete!")
    print("=" * 55)


if __name__ == "__main__":
    run_sldro()