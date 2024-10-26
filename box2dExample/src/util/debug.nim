## Implements useful debugging callbacks.

import math

import box2d
import raylib

import conversions


proc drawSolidPolygon*(transform: b2Transform, vertices: ptr b2Vec2, vertexCount: cint, radius: cfloat, color: b2HexColor, context: pointer) {.cdecl.} = 
    let arr = cast[ptr UncheckedArray[b2Vec2]](vertices)
    var vectors: seq[Vector2] = newSeqOfCap[Vector2](vertexCount+2)

    vectors.add(transform.p.toRaylib)
    vectors.add(transform.b2TransformPoint(arr[0]).toRaylib)

    for i in 0..<vertexCount:
        vectors.add(transform.b2TransformPoint(arr[vertexCount - 1 - i]).toRaylib)

    drawTriangleFan(vectors, White)


## Create a debugDraw object with noop callbacks
## 
## Implement these to define your own debug functionality
proc noopDebugDraw*(): b2DebugDraw = 
    var debugDraw: b2DebugDraw

    {.push cdecl.}
    debugDraw.DrawCircle = proc (center: b2Vec2, radius: cfloat, color: b2HexColor, context: pointer) = discard
    debugDraw.DrawPoint = proc (p: b2Vec2, size: cfloat, color: b2HexColor, context: pointer) = discard
    debugDraw.DrawPolygon = proc (vertices: ptr b2Vec2, vertexCount: cint, color: b2HexColor, context: pointer) = discard
    debugDraw.DrawSegment = proc (p1: b2Vec2, p2: b2Vec2, color: b2HexColor, context: pointer) = discard
    debugDraw.DrawSolidCapsule = proc (p1: b2Vec2, p2: b2Vec2, radius: cfloat, color: b2HexColor, context: pointer) = discard
    debugDraw.DrawSolidCircle = proc (transform: b2Transform, radius: cfloat, color: b2HexColor, context: pointer) = discard
    debugDraw.DrawSolidPolygon = proc (transform: b2Transform, vertices: ptr b2Vec2, vertexCount: cint, radius: cfloat, color: b2HexColor, context: pointer) = discard
    debugDraw.DrawTransform = proc (transform: b2Transform, context: pointer) = discard
    debugDraw.DrawString = proc (p: b2Vec2, s: cstring, context: pointer) = discard
    {.pop.}

    debugDraw