
# Predicts future order demand based on history

import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'app'))
from db_connect import get_connection


def generate_sample_history():
    """
    Generates fake order history for last 30 days.
    In real system this comes from database.
    """
    np.random.seed(42)
    dates = []
    order_counts = []

    base_date = datetime.now() - timedelta(days=30)

    for i in range(30):
        current_date = base_date + timedelta(days=i)
        dates.append(current_date.strftime("%Y-%m-%d"))

        # Weekends have more orders
        if current_date.weekday() >= 5:
            count = np.random.randint(15, 25)
        else:
            count = np.random.randint(8, 15)

        order_counts.append(count)

    return pd.DataFrame({
        "date": dates,
        "order_count": order_counts
    })


def forecast_demand(days_ahead=7):
    """
    Predicts order demand for next N days
    using moving average method.
    Simple but effective for university project.
    """


    df = generate_sample_history()

    print("--- Last 7 Days Order History ---")
    print(df.tail(7).to_string(index=False))

    # Calculate 7-day moving average
    window = 7
    df['moving_avg'] = df['order_count'].rolling(window=window).mean()

    # Get last moving average as base prediction
    last_avg = df['moving_avg'].dropna().iloc[-1]

    # Generate predictions for next N days
    predictions = []
    base_date = datetime.now()

    for i in range(1, days_ahead + 1):
        future_date = base_date + timedelta(days=i)

        # Add weekend boost
        if future_date.weekday() >= 5:
            predicted = round(last_avg * 1.4)
        else:
            predicted = round(last_avg)

        # Calculate vehicles needed
        # Assume each vehicle handles 4 orders
        vehicles_needed = max(1, round(predicted / 4))

        predictions.append({
            "date":            future_date.strftime("%Y-%m-%d"),
            "day":             future_date.strftime("%A"),
            "predicted_orders": int(predicted),
            "vehicles_needed":  int(vehicles_needed)
        })

    return predictions


def print_forecast(predictions):
    """
    Prints forecast results in simple English
    """
    print("\n--- Demand Forecast (Next 7 Days) ---")
    print(f"{'Date':<15} {'Day':<12} {'Orders':<10} {'Vehicles'}")
    print("-" * 50)

    for p in predictions:
        print(f"{p['date']:<15} "
              f"{p['day']:<12} "
              f"{p['predicted_orders']:<10} "
              f"{p['vehicles_needed']}")


    avg_orders = np.mean([p['predicted_orders'] for p in predictions])
    max_orders = max(p['predicted_orders'] for p in predictions)
    max_day    = next(p['day'] for p in predictions
                      if p['predicted_orders'] == max_orders)

    print("\n--- Forecast Summary ---")
    print(f"Average daily orders : {avg_orders:.1f}")
    print(f"Busiest day          : {max_day} ({max_orders} orders)")
    print(f"Max vehicles needed  : {max(p['vehicles_needed'] for p in predictions)}")


if __name__ == "__main__":
    print("--- Running Demand Forecasting ---")
    predictions = forecast_demand(days_ahead=7)
    print_forecast(predictions)
    print("\n--- Forecasting Complete ---")