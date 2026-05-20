//
//  MerchantKeywordService.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman  on 22/11/1447 AH.
//



/**
 /MerchantKeywordService
 JSON Matching
 هذه نشيك عليها بالاول من ملف ال Json
 */
import Foundation

// النتيجة النهائية بعد البحث عن التاجر والتصنيف
struct MerchantKeywordResult {
    let merchantName: String
    let categoryName: String
}

final class MerchantKeywordService {
    
    // اسم ملف الـ JSON الموجود داخل Resources
    private let fileName = "merchant_keywords"
    
    // يبحث عن اسم التاجر داخل نص الرسالة ويرجع التصنيف المناسب
    func detectMerchant(in message: String) -> MerchantKeywordResult? {
        
        // يقرأ الكلمات المفتاحية من ملف JSON
        let keywords = loadKeywords()
        
        // ينظف النص لتسهيل عملية البحث
        let normalizedMessage = normalize(message)
        
        print("🔎 Searching merchant in:", normalizedMessage)
        
        // يمر على جميع التصنيفات والكلمات المفتاحية
        for (categoryName, merchants) in keywords {
            for merchant in merchants {
                
                let normalizedMerchant = normalize(merchant)
                
                // يتحقق إذا الرسالة تحتوي على اسم التاجر
                if normalizedMessage.contains(normalizedMerchant) {
                    
                    print("✅ Merchant matched:", merchant, "Category:", categoryName)
                    
                    return MerchantKeywordResult(
                        merchantName: merchant.capitalized,
                        categoryName: categoryName
                    )
                }
            }
        }
        
        // إذا لم يتم العثور على أي تاجر
        print("⚠️ No merchant keyword matched")
        return nil
    }
    
    // يقرأ ملف merchant_keywords.json (bundle + user overrides on device)
    func loadKeywords() -> [String: [String]] {
        MerchantKeywordStore.shared.loadKeywords()
    }

    /// Sorted category names from merchant_keywords.json.
    func allCategoryNames() -> [String] {
        MerchantKeywordStore.shared.allCategoryNames()
    }
    
    // ينظف النص ويوحد شكله قبل المقارنة
    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "*", with: " ")
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
    }
}
