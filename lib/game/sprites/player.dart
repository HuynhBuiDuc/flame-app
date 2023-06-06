// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_flutter/game/sprites/platform.dart';
import 'package:flame_flutter/game/sprites/powerup.dart';
import 'package:flutter/services.dart';

import '../doodle_dash.dart';
// Core gameplay: Import sprites.dart

enum PlayerState {
  left,
  right,
  center,
  rocket,
  nooglerCenter,
  nooglerLeft,
  nooglerRight
}

class Player extends SpriteGroupComponent<PlayerState>
    with HasGameRef<DoodleDash>, KeyboardHandler, CollisionCallbacks {
  Player({
    super.position,
    required this.character,
    this.jumpSpeed = 600,
  }) : super(
          size: Vector2(79, 109),
          anchor: Anchor.center,
          priority: 1,
        );

  int _hAxisInput = 0;
  final int movingLeftInput = -1;
  final int movingRightInput = 1;
  Vector2 _velocity = Vector2.zero();

  bool get isMovingDown => _velocity.y > 0;
  Character character;
  double jumpSpeed;

  // Core gameplay: Add _gravity property
  final double _gravity = 9;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(CircleHitbox());
    await _loadCharacterSprites(); // Add this line
    current = PlayerState.center;
    // Core gameplay: Add circle hitbox to Dash

    // Add a Player to the game: loadCharacterSprites
    // Add a Player to the game: Default Dash onLoad to center state
  }

  @override
  void update(double dt) {
    // Add a Player to the game: Add game state check
    // Add lines from here...
    if (gameRef.gameManager.isIntro || gameRef.gameManager.isGameOver) return;

    _velocity.x = _hAxisInput * jumpSpeed;
    // Add a Player to the game: Add calcualtion for Dash's horizontal velocity

    final double dashHorizontalCenter = size.x / 2;

    // Add a Player to the game: Add infinite side boundaries logic

    if (position.x < dashHorizontalCenter) {
      // Add lines from here...
      position.x = gameRef.size.x - (dashHorizontalCenter);
    }
    if (position.x > gameRef.size.x - (dashHorizontalCenter)) {
      position.x = dashHorizontalCenter;
    }
    _velocity.y += _gravity;
    // Core gameplay: Add gravity
    position += _velocity * dt;
    // Add a Player to the game: Calculate Dash's current position based on
    // her velocity over elapsed time since last update cycle
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;

    // Add a Player to the game: Add keypress logic
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      moveLeft();
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      moveRight();
    } // ... to here.

    // During development, it's useful to "cheat"
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      // jump();
    }
    return true;
  }

  void moveLeft() {
    _hAxisInput = 0;
    if (isWearingHat) {                                       // Add lines from here...
      current = PlayerState.nooglerLeft;
    } else if (!hasPowerup) {                                           // ... to here.
      current = PlayerState.left;
    }


    _hAxisInput += movingLeftInput;
    // Add a Player to the game: Add logic for moving left
  }

  void moveRight() {
    _hAxisInput = 0;
    if (isWearingHat) {                                       // Add lines from here...
      current = PlayerState.nooglerRight;
    } else if (!hasPowerup) {                                            //... to here.
      current = PlayerState.right;
    }

    _hAxisInput += movingRightInput;
    // Add a Player to the game: Add logic for moving right
  }

  void resetDirection() {
    _hAxisInput = 0;
  }

  // Powerups: Add hasPowerup getter
  bool get hasPowerup =>                                      // Add lines from here...
  current == PlayerState.rocket ||
      current == PlayerState.nooglerLeft ||
      current == PlayerState.nooglerRight ||
      current == PlayerState.nooglerCenter;
  // Powerups: Add isInvincible getter
  bool get isInvincible => current == PlayerState.rocket;
  // Powerups: Add isWearingHat getter
  bool get isWearingHat =>
      current == PlayerState.nooglerLeft ||
          current == PlayerState.nooglerRight ||
          current == PlayerState.nooglerCenter;
  // Core gameplay: Override onCollision callback
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is EnemyPlatform && !isInvincible) {                           // Add lines from here...
      gameRef.onLose();
      return;
    }
    bool isCollidingVertically =
        (intersectionPoints.first.y - intersectionPoints.last.y).abs() < 5;

    if (isMovingDown && isCollidingVertically) {
      current = PlayerState.center;
      if (other is NormalPlatform) {
        jump();
        return;
      } else if (other is SpringBoard) {
        // Add lines from here...
        jump(specialJumpSpeed: jumpSpeed * 2);
        return;
      } else if (other is BrokenPlatform &&
          other.current == BrokenPlatformState.cracked) {
        jump();
        other.breakPlatform();
        return;
      }
    }
    if (!hasPowerup && other is Rocket) {                    // Add lines from here...
      current = PlayerState.rocket;
      other.removeFromParent();
      jump(specialJumpSpeed: jumpSpeed * other.jumpSpeedMultiplier);
      return;
    } else if (!hasPowerup && other is NooglerHat) {
      if (current == PlayerState.center) current = PlayerState.nooglerCenter;
      if (current == PlayerState.left) current = PlayerState.nooglerLeft;
      if (current == PlayerState.right) current = PlayerState.nooglerRight;
      other.removeFromParent();
      _removePowerupAfterTime(other.activeLengthInMS);
      jump(specialJumpSpeed: jumpSpeed * other.jumpSpeedMultiplier);
      return;
    }
  }

  // Core gameplay: Add a jump method
  void jump({double? specialJumpSpeed}) {
    _velocity.y = specialJumpSpeed != null ? -specialJumpSpeed : -jumpSpeed;
  }

  void _removePowerupAfterTime(int ms) {
    Future.delayed(Duration(milliseconds: ms), () {
      current = PlayerState.center;
    });
  }

  void setJumpSpeed(double newJumpSpeed) {
    jumpSpeed = newJumpSpeed;
  }

  void reset() {
    _velocity = Vector2.zero();
    current = PlayerState.center;
  }

  void resetPosition() {
    position = Vector2(
      (gameRef.size.x - size.x) / 2,
      (gameRef.size.y - size.y) / 2,
    );
  }

  Future<void> _loadCharacterSprites() async {
    // Load & configure sprite assets
    final left = await gameRef.loadSprite('game/${character.name}_left.png');
    final right = await gameRef.loadSprite('game/${character.name}_right.png');
    final center =
        await gameRef.loadSprite('game/${character.name}_center.png');
    final rocket = await gameRef.loadSprite('game/rocket_4.png');
    final nooglerCenter =
        await gameRef.loadSprite('game/${character.name}_hat_center.png');
    final nooglerLeft =
        await gameRef.loadSprite('game/${character.name}_hat_left.png');
    final nooglerRight =
        await gameRef.loadSprite('game/${character.name}_hat_right.png');

    sprites = <PlayerState, Sprite>{
      PlayerState.left: left,
      PlayerState.right: right,
      PlayerState.center: center,
      PlayerState.rocket: rocket,
      PlayerState.nooglerCenter: nooglerCenter,
      PlayerState.nooglerLeft: nooglerLeft,
      PlayerState.nooglerRight: nooglerRight,
    };
  }
}
