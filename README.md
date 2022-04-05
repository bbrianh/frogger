# CSC258 Winter 2022 Assembly Final Project
University of Toronto, St. George

Author: Man Chon Ho

## Bitmap Display Configuration:
- Unit width in pixels: 4
- Unit height in pixels: 4
- Display width in pixels: 512
- Display height in pixels: 512
- Base Address for Display: 0x10000000 (global data)

## Gameplay screen
![Gameplay screen](/img/gameplay.png)

## Additional features
- Two player mode (Control description written below)
- Display score
- Display remaining life
- Add a timer to the game
- Add a thrid row to each section
- Objects in different rows move in different speed

## Any additional information:
- Two player control: wasd for p1, ijkl for p2
- Collision detection:
	- A frog is considered "crashed by a car" when one of its body part overlaps with a car
	- A frog is considered "drown" when its main body is not fully on a log (The limbs can be outside of the log)
	- A frog is considered "goal" when its main body is full inside the goal (The limbs can be outside the goal region)
- Scoring rule:
	- 10 points to a new step forward
	- 50 base points + 20 * remaining time to the player who reaches an empty goal
- Win condition:
	- You win if your opponent loses all 3 lives
	- If both players are alive when all 5 goals are filled, the player who have the higher score wins

- object:
	- The object patterns and speed can be modified by changing the corresponding bit flag in the data segment

## Running the game
You could use Mars 4.5 Assembly simulator to run the game. Open "Bit map display" and "Keyboard display and MMIO simulator" in Tools and use the correct configuration listed above.
