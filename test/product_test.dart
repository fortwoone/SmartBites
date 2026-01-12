import "package:flutter_test/flutter_test.dart";
import "package:smartbites/models/product.dart";

void main(){
  test(
      "Product example",
          (){
        final Product p = Product(barcode: "blabla");
        expect("blabla", p.barcode);
        expect("unknown", p.novaGroup);
        expect(null, p.name);
        expect(null, p.frName);
        expect(null, p.enName);
        expect(null, p.brands);
        expect(null, p.ingredientsText);
        expect(null, p.nutriments);
        expect(null, p.imageURL);
        expect(null, p.imageSmallURL);
        expect(null, p.nutriscoreGrade);
      }
  );
}