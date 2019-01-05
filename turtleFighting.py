# Author : Miles Keppler
# Assignment : Final Project
# Class : CSCI 141

# TURTLE FIGHTING

from turtle import*
# for random turtle spawning
from random import*

def main() :
    # print rules and explain the game
    introduction()
    borderTurtle = initWindow()
    # only 2 players
    playerOne = initTurtle(randrange(-250, 250), randrange(-250, 250), "blue", randrange(0, 360))
    playerTwo = initTurtle(randrange(-250, 250), randrange(-250, 250), "purple", randrange(0, 360))
    for t in range(101) :
        if t % 2 == 0 :
            playerTurtle = playerOne
            opponentTurtle = playerTwo
        else :
            playerTurtle = playerTwo
            opponentTurtle = playerOne
        if playerTurn(playerTurtle, t, opponentTurtle, borderTurtle) :
            break
        # 100 turns between 2 players
        if t == 100 :
            drawGame([playerOne, playerTwo, borderTurtle])
            break

# string
def intInp(string) :
    # return errors for noninteger inputs without ending the program
    # allow user errors to not break game
    inp = True
    while inp :
        inp = False
        userInp = input(string)
        for char in userInp :
            if char not in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] :
                inp = True
                print("Please input an integer value.")
                break
    return int(userInp)

def initWindow() :
    wn = Screen()
    wn.bgcolor("light green")
    borderTurtle = initTurtle(-350, 350, "red", 0)
    borderTurtle.down()
    for turn in range(0, 4) :
        borderTurtle.forward(700)
        borderTurtle.right(90)
    borderTurtle.up()
    return borderTurtle

# float, float, string(color name), float(angle)
def initTurtle(xVal, yVal, colorVal, orientationVal) :
    player = Turtle()
    player.up()
    player.shape("turtle")
    player.color(colorVal)
    player.goto(xVal, yVal)
    player.left(orientationVal)
    return player
    
def introduction() :
    # split lines for easy editing
    print("\n Turtle Fighting")
    print("\n ======================== \n")
    print("This is a siege turtle battle simulator.")
    print("You will control a colored turtle, and battle in a forest.")
    print("Your goal is to shoot the other turtle.")
    print("Remember, your bullets are massive.")
    print("Each turn, you get two actions, move or shoot.")
    print("Movement allows you to turn and move forward.")
    print("You have 200 units to split between each.")
    print("Every time you move, you may turn, then move, then turn.")
    print("No other method of movement division is allowed.")
    print("Do not anger the border turtle. Do not cross its trail.")
    print("Player 1 gets only one action on their first turn.")
    print("Player 1 is blue. Player 2 is purple.")
    print("All numerical inputs should be integers.")
    print("If you fail to communicate to your turtle, it may misbehave.")
    print("Good luck.")
    print("\n ======================== \n")

# turtle, integer, turtle
def moveTurtle(playerTurtle, units, opponentTurtle) :
    distance = intInp("How far forward would you like to move?")
    if distance < 0 :
        distance = 0 - distance
        print("Negative values not accepted. Switched to positive value.")
    if distance > units :
        distance = units
    units = units - distance
    playerTurtle.forward(distance)
    # turtles can't be in the same spot
    while collisionCheck(playerTurtle, 15, opponentTurtle, 15) :
        playerTurtle.backward(1)
    return units

# turtle, turtle, int([-1, 1])
def borderControlX(playerTurtle, borderTurtle, xSign) :
    for side in range(0, 4) :
        for dist in range(0, 700, 5) :
            if int(borderTurtle.ycor()) == int(playerTurtle.ycor()) - int(playerTurtle.ycor()) % 5 and borderTurtle.xcor() * xSign > 0 :
                borderFetch(playerTurtle, borderTurtle)
            borderTurtle.forward(5)
        borderTurtle.right(90)

# turtle, turtle, int([-1, 1])
def borderControlY(playerTurtle, borderTurtle, ySign) :
    for side in range(0, 4) :
        for dist in range(0, 700, 5) :
            if int(borderTurtle.xcor()) == int(playerTurtle.xcor()) - int(playerTurtle.xcor()) % 5 and borderTurtle.ycor() * ySign > 1 :
                borderFetch(playerTurtle, borderTurtle)
            borderTurtle.forward(5)
        borderTurtle.right(90)

# turtle, turtle, int([-1, 1]), int([-1, 1])
def borderControlXY(playerTurtle, borderTurtle, xSign, ySign) :
    for side in range(0, 4) :
        if borderTurtle.xcor() * xSign > 0 and borderTurtle.ycor() * ySign > 0 :
            borderFetch(playerTurtle, borderTurtle)
        borderTurtle.forward(700)
        borderTurtle.right(90)

# turtle, turtle
def borderFetch(playerTurtle, borderTurtle) :
    borderTurtle.speed("slowest")
    playerTurtle.speed("slow")
    borderVal = borderTurtle.position()
    borderTurtle.goto(playerTurtle.position())
    playerTurtle.goto(borderVal)
    borderTurtle.goto(borderVal)
    borderTurtle.speed("normal")
    playerTurtle.speed("normal")

# turtle, turtle
def borderTest(playerTurtle, borderTurtle) :
    x = 0
    y = 0
    if int(playerTurtle.xcor()) > 350 :
        x = 1
    elif int(playerTurtle.xcor()) < -350 :
        x = -1
    if int(playerTurtle.ycor()) > 350 :
        y = 1
    elif int(playerTurtle.ycor()) < -350 :
        y = -1
    if x != 0 and y == 0 :
        borderControlX(playerTurtle, borderTurtle, x)
    elif x == 0 and y != 0 :
        borderControlY(playerTurtle, borderTurtle, y)
    elif x != 0 and y != 0 :
        borderControlXY(playerTurtle, borderTurtle, x, y)

# turtle, integer
def turnTurtle(playerTurtle, units) :
    angle = intInp("How many degrees would you like to turn?")
    if angle < 0 :
        angle = 0 - angle
        print("Negative values not accepted. Switched to positive value.")
    if angle > units :
        angle = units
        print("Corrected to", angle, "degrees.")
    units = units - angle
    if angle != 0 :
        while True :
            direction = input("Would you like to turn right or left?")
            if direction == "left" or direction == "right" :
                break
            else :
                print("Please input 'left' or 'right'")
    else :
        direction = "left"

    if direction == "left" :
        playerTurtle.left(angle)
    elif direction == "right" :
        playerTurtle.right(angle)
    return units

# turtle, turtle
def fireTurtleCannon(playerTurtle, opponentTurtle) :
    bullet = playerTurtle.clone()
    bullet.shape("classic")
    bullet.color("black")
    for x in range(0, 250, 1) :
        bullet.forward(4)
        if collisionCheck(bullet, 5, opponentTurtle, 15) :
            return True
        if int(bullet.xcor()) > 350 or int(bullet.xcor()) < -350 :
            break
        if int(bullet.ycor()) > 350 or int(bullet.ycor()) < -350 :
            break
    bullet.hideturtle()
    return False

# turtle, integer, turtle, turtle
def playerTurn(playerTurtle, t, opponentTurtle, borderTurtle) :
    print("Player ", t % 2 + 1, "'s turn.", sep="")
    for a in range(2) :
        if action(playerTurtle, t, opponentTurtle, borderTurtle) :
            return True
        if t == 0 :
            break
    return False

# turtle, integer, turtle, turtle
def action(playerTurtle, t, opponentTurtle, borderTurtle) :
    hit = False
    while True :
        act = input("Would you like to move or shoot?")
        if act == "move" :
            moveAction(playerTurtle, opponentTurtle)
            # don't let turtles leave the square
            borderTest(playerTurtle, borderTurtle)
            break
        elif act == "shoot" :
            hit = fireTurtleCannon(playerTurtle, opponentTurtle)
            break
        else :
            print("Please type 'move' or 'shoot'.")
    if hit :
        return victory(t, playerTurtle, opponentTurtle)
    else :
        return False

# turtle, turtle
def moveAction(playerTurtle, opponentTurtle) :
    units = 200
    units = turnTurtle(playerTurtle, units)
    print("You have", units, "units left to move/turn.")
    if units > 0 :
        units = moveTurtle(playerTurtle, units, opponentTurtle)
        print("You have", units, "units left to move/turn.")
    if units > 0 :
        turnTurtle(playerTurtle, units)

# turtle, int, turtle, int
def collisionCheck(objectA, hitboxA, objectB, hitboxB) :
    return ( objectA.ycor() - objectB.ycor() ) ** 2 + ( objectA.xcor() - objectB.xcor() ) ** 2 <= ( hitboxA + hitboxB ) ** 2

# integer, turtle, turtle
def victory(t, playerTurtle, opponentTurtle) :
    print("The winner is Player", t % 2 + 1, "!")
    print("Your victory will be recorded in the score book.")
    scoreBook = open("turtleScores.txt", "a")
    scoreBook.write("Player " + str(t % 2 + 1) + " :\n")
    scoreBook.write("    Hit position " + str(opponentTurtle.position()))
    scoreBook.write("\n        from " + str(playerTurtle.position()) + ".\n")
    scoreBook.write("\n ======================== \n")
    scoreBook.close()
    print("Thank you for playing!")
    print("Press 'ENTER' to exit.")
    input()
    return True

# [turtle1, turtle2, ... turtlen]
def turtlesLeave(turtleList) :
    for turtle in turtleList :
        while True :
            turtle.forward(5)
            if int(turtle.xcor()) > 350 or int(turtle.xcor()) < -350 or int(turtle.ycor()) > 350 or int(turtle.ycor()) < -350 :
                turtle.hideturtle()
                break

# ends game in draw after turns run out. no infinite loop
#[turtle1, turtle2, ... turtlen]
def drawGame(turtleList) :
    scoreBook = open("turtleScores.txt", "a")
    scoreBook.write("The game was a draw.\n")
    scoreBook.write("\n ======================== \n")
    scoreBook.close()
    print("The turtles got tired and are going home.")
    turtlesLeave(turtleList)
    print("The draw will be recorded in the score book.")
    print("Thank you for playing!")
    print("Press 'ENTER' to exit.")
    input()

main()
