# SLDRO - K-Means Clustering Module
# Groups delivery orders by location
# so nearby orders go to the same vehicle

import numpy as np
from sklearn.cluster import KMeans
import sys
import os


sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'app'))
from db_connect import fetch_pending_orders

def cluster_orders(orders, n_clusters=3):
    """
    Groups orders into clusters based on
    drop-off GPS coordinates using K-Means.
    Returns orders with cluster labels assigned.
    """

    if len(orders) == 0:
        print("No orders to cluster.")
        return []


    n_clusters = min(n_clusters, len(orders))

    # Extract GPS coordinates (drop location)
    coordinates = np.array([
        [float(order['drop_lat']), float(order['drop_lng'])]
        for order in orders
    ])

    # Apply K-Means clustering
    kmeans = KMeans(
        n_clusters=n_clusters,
        random_state=42,
        n_init=10
    )
    kmeans.fit(coordinates)

    # Assign cluster label to each order
    for i, order in enumerate(orders):
        order['cluster_id'] = int(kmeans.labels_[i])

    return orders, kmeans.cluster_centers_


def print_cluster_results(orders, centers):
    """
    Prints clustering results in simple English
    """
    print("\n--- Clustering Results ---")
    print(f"Total orders: {len(orders)}")
    print(f"Total clusters: {len(centers)}")

    # Group orders by cluster
    clusters = {}
    for order in orders:
        cid = order['cluster_id']
        if cid not in clusters:
            clusters[cid] = []
        clusters[cid].append(order)

    # Print each cluster
    for cid, cluster_orders in clusters.items():
        lat, lng = centers[cid]
        print(f"\nCluster {cid + 1}:")
        print(f"  Center location: ({lat:.4f}, {lng:.4f})")
        print(f"  Orders in this cluster: {len(cluster_orders)}")
        for order in cluster_orders:
            print(f"    - Order #{order['order_id']} | "
                  f"{order['customer_name']} | "
                  f"Priority: {order['priority']} | "
                  f"Drop: {order['drop_address']}")


if __name__ == "__main__":
    print("--- Running K-Means Clustering ---")

    # Step 1: Fetch orders from database
    orders = fetch_pending_orders()

    if not orders:
        print("No pending orders found.")
    else:
        # Step 2: Run clustering
        orders, centers = cluster_orders(orders, n_clusters=3)

        # Step 3: Print results
        print_cluster_results(orders, centers)

        print("\n--- Clustering Complete ---")
        print("Orders are now grouped by delivery zone.")
        print("Each cluster will be assigned to one vehicle.")