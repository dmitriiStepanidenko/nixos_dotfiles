import sys
from datetime import datetime, timedelta

def calculate_time_increments(start_time_str, delta_minutes):
    # Parse start time
    try:
        start_time = datetime.strptime(start_time_str, "%H:%M")
    except ValueError:
        print("Invalid time format. Please use HH:MM (24-hour format)")
        sys.exit(1)
    
    # Calculate total minutes in a day
    total_minutes = 24 * 60
    
    # Calculate how many increments fit in a day
    max_increments = total_minutes // delta_minutes
    
    print(f"Start time: {start_time.strftime('%H:%M')}")
    print(f"Delta: {delta_minutes} minutes")
    print(f"Time increments:")
    print("-" * 30)
    
    current_time = start_time
    increment = 0
    
    while increment <= max_increments:
        print(f"{increment:02d}. {current_time.strftime('%H:%M')}")
        
        # Add delta to current time
        current_time += timedelta(minutes=delta_minutes)
        increment += 1
        
        # Stop if we've wrapped around past the start time (next day)
        if current_time.strftime('%H:%M') < start_time.strftime('%H:%M'):
            break

def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py <start_time> <delta_minutes>")
        print("Example: python script.py 08:30 45")
        sys.exit(1)
    
    start_time_str = sys.argv[1]
    
    try:
        delta_minutes = int(sys.argv[2])
        if delta_minutes <= 0:
            print("Delta must be a positive number of minutes.")
            sys.exit(1)
    except ValueError:
        print("Invalid delta. Please enter a valid number of minutes.")
        sys.exit(1)
    
    calculate_time_increments(start_time_str, delta_minutes)

if __name__ == "__main__":
    main()
