# Bubble Shooter Game for 8086 Processor
Welcome to the Bubble Shooter game developed for the 8086 processor in assembly language! This game is an **original take-off** for the well known game **Bubble Shooter**, a classic arcade puzzle where the player controls a shooter at the bottom of the screen, aiming to launch colored bubbles towards a cluster of bubbles at the top. The primary objective is to match three or more bubbles of the same color, causing them to burst and disappear from the play area.

## Original Bubble Shooter Game

Bubble Shooter is a classic arcade puzzle game where the player controls a shooter at the bottom of the screen, aiming to launch colored bubbles towards a cluster of bubbles at the top. The primary objective is to match three or more bubbles of the same color, causing them to burst and disappear from the play area. Players must strategically aim and shoot bubbles to create these matches, clear the screen, and prevent the bubbles from reaching the bottom, which would end the game. The game challenges players to achieve high scores by creating chain reactions of bursting bubbles and efficiently managing the growing mass of bubbles. The main goals are to clear as many bubbles as possible, maximize points through strategic shooting, and avoid letting the bubbles overwhelm the player’s position.

## Features and Enhancements
Our version of Bubble Shooter for the 8086 processor includes a unique feature:
- **Time Integration**: An orange timer on the right side of the screen indicates when a new row of bubbles will appear. This timer accelerates if the player shoots without popping any bubbles, adding an element of urgency and strategy to the game.

## Scoring System

The scoring system in our Bubble Shooter game rewards players based on the number of bubbles they burst in a single shot, with additional bonuses for larger bursts and consecutive successful shots. The base scoring rules are as follows:

- Bursting exactly 3 bubbles grants 100 points.
- For each bubble beyond the initial 3, an additional 50 points are awarded.
- Bursting 5 or more bubbles grants an additional 500 points for each bubble beyond the initial 3, significantly increasing the score for larger bursts.
- If a player achieves a double successful explosion, where two bursts occur in quick succession, the score of the second burst is doubled, adding an exciting multiplier effect to the gameplay.

The scoring system ensures that players are rewarded for both precision and strategic play, encouraging them to aim for larger bursts and consecutive successful shots to maximize their score.

## How to Play

1. **Control the Shooter**: Use the mouse to aim and press the left mouse button to shoot the bubble towards the cluster at the top.
2. **Match Bubbles**: Aim to match three or more bubbles of the same color to make them burst and disappear.
3. **Avoid Overwhelm**: Prevent the bubbles from reaching the bottom of the screen to continue playing.
4. **Score Points**: Create chain reactions of bursting bubbles to maximize your score.

## Technical Details

- **Assembly Language**: The game is developed in assembly language for the 8086 processor.
- **Graphic Mode 13h**: Utilizes INT 10h for setting up the graphics mode.
- **Mouse Input**: Captures mouse coordinates for aiming and shooting.
- **Custom Collision Detection**: Functions are implemented to check for collisions with other bubbles and walls, ensuring accurate and responsive gameplay.
- **Fixed-Point Arithmetic**: The game uses an 8.8 fixed-point format to handle precise calculations for the ball's movement.
- **Wall Bounce Mechanism**: The ball reverses its direction upon collision with the wall, but only on the x-axis, preserving the y-axis movement.
- **Recursive Chain Detection**: A recursive function is triggered when the ball is shot to search for all bubbles of the same color as the player's ball. If a chain of at least three matching colors is found, all bubbles in the chain are deleted.
- **Score Management**: Players can achieve a maximum score of 50,000 points, rewarding strategic play and efficient bubble matching.

## Installation

1. Clone this repository to your local machine.
2. Assemble the code using an appropriate assembler for the 8086 processor.
3. Load and run the game on an 8086 emulator or compatible hardware.

## License
This game and all of his files were created by **Tal Barmocha** and **Shay Rask**
This project is licensed under the MIT License.

---
Enjoy playing Bubble Shooter on your 8086 processor and experience the unique enhancements we've made to this classic game!
