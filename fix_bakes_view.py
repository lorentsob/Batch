with open("Levain/Features/Bakes/BakesView.swift", "r") as f:
    lines = f.readlines()

new_lines = lines[:163] + lines[507:]

with open("Levain/Features/Bakes/BakesView.swift", "w") as f:
    f.writelines(new_lines)
