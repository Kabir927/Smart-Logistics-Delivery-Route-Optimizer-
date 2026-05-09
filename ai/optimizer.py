# SLDRO - Route Optimizer Module
# Developer: Kabir
# Finds best delivery order using Nearest Neighbor algorithm

import numpy as np
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'app'))
from db_connect import fetch_pending_orders, save_route
from clustering import cluster_orders


def calculate_distance(lat1, lng1, lat2, lng2):
    """
    Calculates distance between two GPS points
    using Haversine formula (gives km distance)
    """
    R = 6371  # Earth radius in km

    lat1, lng1 = map(np.radians, [float(lat1), float(lng1)])
    lat2, lng2 = map(np.radians, [float(lat2), float(lng2)])

    dlat = lat2 - lat1
    dlng = lng2 - lng1

    a = (np.sin(dlat / 2) ** 2 +
         np.cos(lat1) * np.cos(lat2) * np.sin(dlng / 2) ** 2)

    c = 2 * np.arcsin(np.sqrt(a))
    return R * c


def nearest_neighbor_route(orders):
    """
    Finds best delivery sequence using
    Nearest Neighbor heuristic algorithm.
    Starts from first order, always goes
    to the closest unvisited order next.
    """
    if len(orders) == 0:
        return [], 0

    if len(orders) == 1:
        return orders, 0

    unvisited = orders.copy()
    route     = []
    total_distance = 0

    # Start from first order
    current = unvisited.pop(0)
    route.append(current)

    # Keep visiting nearest unvisited order
    while unvisited:
        nearest      = None
        nearest_dist = float('inf')

        for order in unvisited:
            dist = calculate_distance(
                current['drop_lat'], current['drop_lng'],
                order['drop_lat'],   order['drop_lng']
            )
            if dist < nearest_dist:
                nearest_dist = dist
                nearest      = order

        route.append(nearest)
        total_distance += nearest_dist
        current = nearest
        unvisited.remove(nearest)

    return route, round(total_distance, 2)


def optimize_all_clusters(orders, centers, vehicles):
    """
    Optimizes route for each cluster
    and assigns a vehicle to each cluster
    """
    results = []

    # Get unique clusters
    cluster_ids = list(set(o['cluster_id'] for o in orders))

    for i, cid in enumerate(cluster_ids):
        # Get orders in this cluster
        cluster_orders = [o for o in orders if o['cluster_id'] == cid]

        # Optimize route for this cluster
        optimized_route, total_dist = nearest_neighbor_route(cluster_orders)

        # Estimate time (assume 30 km/h average speed)
        estimated_time = round((total_dist / 30) * 60, 1)

        # Assign vehicle (cycle through available vehicles)
        vehicle = vehicles[i % len(vehicles)]

        results.append({
            "cluster_id":      cid,
            "vehicle_id":      vehicle["id"],
            "vehicle_plate":   vehicle["plate"],
            "route":           optimized_route,
            "total_distance":  total_dist,
            "estimated_time":  estimated_time
        })

    return results


def print_optimized_routes(results):
    """
    Prints optimized routes in simple English
    """
    print("\n--- Optimized Route Results ---")

    for r in results:
        print(f"\nCluster {r['cluster_id'] + 1} "
              f"-> Vehicle: {r['vehicle_plate']}")
        print(f"  Total distance : {r['total_distance']} km")
        print(f"  Estimated time : {r['estimated_time']} minutes")
        print(f"  Delivery sequence:")

        for step, order in enumerate(r['route'], 1):
            print(f"    Step {step}: Order #{order['order_id']} | "
                  f"{order['customer_name']} | "
                  f"{order['drop_address']} | "
                  f"Priority: {order['priority']}")


if __name__ == "__main__":
    print("--- Running Route Optimizer ---")

    # Step 1: Fetch orders from database
    orders = fetch_pending_orders()

    if not orders:
        print("No pending orders found.")
    else:
        # Step 2: Cluster orders by location
        orders, centers = cluster_orders(orders, n_clusters=3)

        # Step 3: Define available vehicles
        vehicles = [
            {"id": 1, "plate": "ABC-123", "type": "bike"},
            {"id": 2, "plate": "XYZ-456", "type": "van"},
            {"id": 3, "plate": "LMN-789", "type": "truck"}
        ]

        # Step 4: Optimize routes per cluster
        results = optimize_all_clusters(orders, centers, vehicles)

        # Step 5: Print results
        print_optimized_routes(results)

        # Step 6: Save routes to database
        print("\n--- Saving Routes to Database ---")
        for r in results:
            save_route(
                vehicle_id     = r['vehicle_id'],
                route_name     = f"Route-Cluster-{r['cluster_id'] + 1}",
                total_distance = r['total_distance'],
                estimated_time = r['estimated_time'],
                cluster_id     = r['cluster_id']
            )

        print("\n--- Route Optimization Complete ---")
        print(f"Total clusters optimized : {len(results)}")
        total = sum(r['total_distance'] for r in results)
        print(f"Total distance all routes: {round(total, 2)} km")