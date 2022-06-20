import 'package:aldrin/components/nodes.dart';
import 'package:aldrin/components/elements.dart';
import 'package:test/test.dart';

void main() {
  test('Should render div', () {
    expect(DivNode(child: TextElement('test')).render(), equals('<div>test</div>'));
  });
}
