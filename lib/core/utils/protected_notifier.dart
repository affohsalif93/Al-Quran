import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

abstract class ProtectedNotifier<T> extends Notifier<T> {
  @protected
  @override
  T get state => super.state;

  @protected
  @override
  set state(T newState) => super.state = newState;

  T get exposedState => super.state;
}