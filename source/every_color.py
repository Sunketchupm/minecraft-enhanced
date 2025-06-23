with open("colors.txt", "w") as file:
    for r in range(256):
        for g in range(256):
            for b in range(256):
                file.write(f"({r}, {g}, {b})\n")