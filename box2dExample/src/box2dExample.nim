## This example demonstrates creating and deleting a large number of physics bodies in an
## unbounded area. Because of how box2d performs spatial queries to optimize collision checks,
## this will have significantly better performance than the bounded `example_circles`.

import box2d
import raylib

import util/[conversions, debug, window, sized_stack]


# Physics simulation substeps
const subStepCount = 2

# Define initial window dimensions
const initialWidth = 1000
const initialHeight = (initialWidth * (9 / 16)).int32

# Physics shape properties. Can be reused
const density = 1.0f
const friction = 0.2f
const restitution = 0.1f

var physicsShapeDef = b2DefaultShapeDef()
physicsShapeDef.density = density
physicsShapeDef.friction = friction
physicsShapeDef.restitution = restitution


## Initialize physics with a gravity vector
proc initPhysics(): b2WorldId =
    var worldDef = b2DefaultWorldDef()
    worldDef.gravity = b2Vec2(x: 0.0f, y: 10.0f)
    b2CreateWorld(worldDef.addr)


## Create a debugDraw object with drawing callbacks
var debugDraw: b2DebugDraw = noopDebugDraw()
debugDraw.DrawSolidPolygon = drawSolidPolygon
debugDraw.drawShapes = true

let worldId = initPhysics()

const objectsPerFrameHeld = 4


## Make box body
proc makeBox(worldId: b2WorldId, position: b2Vec2): b2BodyId =
    var bodyDef = b2DefaultBodyDef()

    bodyDef.bodyType = b2_dynamicBody
    bodyDef.position = position

    let bodyId = b2CreateBody(worldId, bodyDef.addr)
    let box = b2MakeBox(0.1f, 0.1f)

    discard b2CreatePolygonShape(bodyId, physicsShapeDef.addr, box.addr)
    bodyId


## Holds bodyIds for all spawned boxes
var boxStack: SizedStack[5000, b2BodyId]
boxStack.clear(b2_nullBodyId)


## Destroy a box in the stack with null body check
proc destroyBoxSafe(bodyId: b2BodyId) =
    if bodyId != b2_nullBodyId:
        b2DestroyBody(bodyId)


## Destroy a box in the stack, no null body check
proc destroyBoxUnsafe(bodyId: b2BodyId) =
    b2DestroyBody(bodyId)


## Create circle under mouse position, and delete old circles if stack is full.
proc mouseDown(worldId: b2WorldId, mousePosB2: b2Vec2) =
    for _ in 0..<objectsPerFrameHeld:
        boxStack.insert(worldId.makeBox(mousePosB2), destroyBoxUnsafe)


var currentWidth: float32
var currentHeight: float32
var boundShapeDown: b2ShapeId


## Create world bounds
proc makeBounds*(worldId: b2WorldId, density: float32, friction: float32,
        restitution: float32) =
    var bodyDef = b2DefaultBodyDef()

    currentWidth = getScreenWidth().float32.toB2
    currentHeight = getScreenHeight().float32.toB2

    var segmentDown: b2Segment
    segmentDown.point1 = b2Vec2(x: 0, y: currentHeight)
    segmentDown.point2 = b2Vec2(x: currentWidth, y: currentHeight)

    let boundBodyDown = b2CreateBody(worldId, bodyDef.addr)
    boundShapeDown = b2CreateSegmentShape(boundBodyDown, physicsShapeDef.addr,
            segmentDown.addr)


## Update world bounds to current window size.
##
## This is not graceful, and will throw bodies outside world bounds
proc setBounds*(worldId: b2WorldId) =
    let width = getScreenWidth().float32.toB2
    let height = getScreenHeight().float32.toB2

    # If no window size change has been made, return early.
    # All objects on the ground will be kept awake if
    # shapes are updated every frame.
    if currentHeight == height and currentWidth == width:
        return

    currentHeight = height
    currentWidth = width

    var segmentDown: b2Segment
    segmentDown.point1 = b2Vec2(x: 0, y: height)
    segmentDown.point2 = b2Vec2(x: width, y: height)
    b2Shape_SetSegment(boundShapeDown, segmentDown.addr)


## Top-level function that initializes window and performs game loops
proc main() =

    # Prevents sudden physics simulation jumps (usually occurs when the window is minimized)
    const maxDeltaPerFrame: float32 = 1/30

    # Called after window initialization but before first draw
    proc postInit() {.cdecl.} =
        worldId.makeBounds(density, friction, restitution)

    # Performs physics step and window update
    proc mainLoop() {.cdecl.} =

        worldId.setBounds()

        let deltaTime = min(getFrameTime(), maxDeltaPerFrame)

        b2World_Step(worldId, deltaTime, subStepCount)

        beginDrawing()
        clearBackground(Color(r: 30, g: 30, b: 30, a: 255))

        let mousePosB2 = getMousePosition().toB2

        if isMouseButtonDown(MouseButton.Left):
            mouseDown(worldId, mousePosB2)

        if isKeyPressed(R):
            boxStack.clear(b2_nullBodyId, destroyBoxSafe)

        b2World_Draw(worldId, debugDraw.addr)

        # If no active bodies, show helpful message
        if boxStack.length == 0:
            let font = getFontDefault()
            let fontSize = 50.0
            let fontSpacing = 5.0
            let startMessage = "click and drag to spawn boxes"
            let startMessageDims = measureText(font, startMessage, fontSize, fontSpacing)

            drawText(
                font,
                startMessage,
                Vector2(
                    x: (initialWidth.float32 - startMessageDims.x) / 2,
                    y: (initialHeight.float32 - startMessageDims.y) / 2
                ),
                fontSize,
                fontSpacing,
                LightGray
            )

        endDrawing()

    windowMain(initialWidth, initialHeight, "Jon is a developer", mainLoop, postInit)


if isMainModule:
    main()
