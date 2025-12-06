import sys

def calculate_time_fragments(N):
    total_minutes = 24 * 60  # 1440 minutes in a day
    fragment_length = total_minutes / N

    for i in range(N):
        fragment_minutes = i * fragment_length
        hours = int(fragment_minutes // 60)
        minutes = int(fragment_minutes % 60)
        print(f"{i+1:02d}. {hours:02d}:{minutes:02d}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <number>")
        sys.exit(1)

    try:
        num = int(sys.argv[1])
        if num <= 0:
            print("Please enter a positive number.")
            sys.exit(1)
        calculate_time_fragments(num)
    except ValueError:
        print("Invalid input. Please enter a valid integer.")
        sys.exit(1)
