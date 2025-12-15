import "package:food/db_objects/cached_product.dart";
import "package:test/test.dart";

void main(){
    group(
        "Constructor tests",
        (){
            test(
                "Normal constructor",
                (){
                    final p = CachedProduct(
                        barcode: "1122334455667788",
                        img_small_url: "http://some_url.com/img.png",
                        brands: "Random",
                        en_name: "Test Product",
                        fr_name: "Produit de test"
                    );
                    expect("1122334455667788", p.barcode);
                    expect("http://some_url.com/img.png", p.img_small_url);
                    expect("Random", p.brands);
                    expect("Test Product", p.en_name);
                    expect("Produit de test", p.fr_name);
                }
            );

            test(
                "Factory method using a map",
                (){
                    final p = CachedProduct.fromMap(
                        {
                            "barcode": "1122334455667788",
                            "img_small_url": "http://some_url.com/img.png",
                            "brands": "Random",
                            "en_name": "Test Product",
                            "fr_name": "Produit de test"
                        }
                    );
                    expect("1122334455667788", p.barcode);
                    expect("http://some_url.com/img.png", p.img_small_url);
                    expect("Random", p.brands);
                    expect("Test Product", p.en_name);
                    expect("Produit de test", p.fr_name);
                }
            );
        }
    );
}
