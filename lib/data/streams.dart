import 'dart:async';

class DataStream{
  final StreamController<String> _controller=StreamController<String>.broadcast();
  Stream<String> get stream=>_controller.stream;


  void updateData(String data){
    _controller.sink.add(data);
  }

  void dispose(){
    _controller.close();
  }
}

final datastream=DataStream();