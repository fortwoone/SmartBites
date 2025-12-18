class CachedProduct{
    final String barcode;
    final String img_small_url;
    final String brands;
    final String en_name;
    final String fr_name;

    const CachedProduct({
        required this.barcode,
        required this.img_small_url,
        required this.brands,
        required this.en_name,
        required this.fr_name
    });

    factory CachedProduct.fromMap(Map<String, dynamic> orig){
        return CachedProduct(
            barcode: (orig["barcode"] as String?) ?? "",
            img_small_url: (orig["img_small_url"] as String?) ?? "",
            brands: (orig["brands"] as String?) ?? "",
            en_name: (orig["en_name"] as String?) ?? "",
            fr_name: (orig["fr_name"] as String?) ?? ""
        );
    }
}