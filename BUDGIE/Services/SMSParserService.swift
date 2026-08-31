
//
//  TransactionParserService.swift
//  BUDGIE
//
//  Created by Abeer Jeilani Osman on 22/11/1447 AH.
//
// يحلل النص ويحوله إلى Transaction.

import Foundation

// موديل مؤقت يمثل العملية بعد تحليل رسالة البنك
struct ParsedTransaction: Identifiable, Codable {

    let id: UUID
    let merchantName: String?
    let amount: Double?
    let categoryName: String?
    let rawMessage: String
    let date: Date

    init(
        id: UUID = UUID(),
        merchantName: String?,
        amount: Double?,
        categoryName: String?,
        rawMessage: String,
        date: Date = Date()
    ) {
        self.id = id
        self.merchantName = merchantName
        self.amount = amount
        self.categoryName = categoryName
        self.rawMessage = rawMessage
        self.date = date
    }
}

final class SMSParserService {

    // يحلل نص الرسالة ويطلع المبلغ، اسم التاجر، والتصنيف
    func parse(_ message: String) -> ParsedTransaction? {

        // يوحد الأرقام العربية والإنجليزية قبل تحليل الرسالة
        let normalizedMessage = normalizeArabicNumbers(message)

        // يتأكد أن الرسالة تمثل عملية شراء ناجحة
        guard isPurchaseMessage(normalizedMessage) else {
            print("❌ SMS ignored - not a successful purchase")
            print("Message: \(message)")
            return nil
        }

        // يحتوي على المبلغ المستخرج من رسالة البنك
        guard let amount = extractAmount(
            from: normalizedMessage
        ) else {
            print("❌ Purchase detected but amount was not found")
            print("Message: \(message)")
            return nil
        }

        let keywordService = MerchantKeywordService()

        // يبحث داخل merchant_keywords.json عن اسم التاجر والتصنيف
        let keywordResult = keywordService.detectMerchant(
            in: normalizedMessage
        )

        // اسم التاجر النهائي المستخدم داخل التطبيق
        let merchantName =
            keywordResult?.merchantName ??
            extractMerchantName(from: normalizedMessage)

        // التصنيف النهائي للعملية مثل Food أو Transport
        let categoryName = keywordResult?.categoryName

        print("✅ Purchase detected")
        print("💰 Amount: \(amount)")
        print("🏪 Merchant: \(merchantName ?? "Unknown")")
        print("📂 Category: \(categoryName ?? "Unknown")")

        // يرجع العملية بعد التأكد من صحة الرسالة واستخراج بياناتها
        return ParsedTransaction(
            merchantName: merchantName,
            amount: amount,
            categoryName: categoryName,
            rawMessage: message
        )
    }

    // يتأكد أن الرسالة تمثل عملية شراء ناجحة
    private func isPurchaseMessage(_ message: String) -> Bool {

        // يحول النص إلى حروف صغيرة لتسهيل المقارنة
        let text = message.lowercased()

        // رسائل لا نريد اعتبارها عملية شراء
        let ignoredPatterns = [
            "حوالة واردة",
            "حوالة صادرة",
            "تحويل وارد",
            "تحويل صادر",
            "حوالة",
            "تحويل",

            "لا يكفي لإتمام مشترياتك",
            "رصيد غير كاف",
            "الرصيد غير كاف",
            "تم رفض",
            "عملية مرفوضة",
            "العملية مرفوضة",
            "عملية غير ناجحة",
            "العملية غير ناجحة",
            "تعذر تنفيذ",
            "لم تتم العملية",
            "فشلت العملية",

            "declined",
            "insufficient",
            "failed",
            "unsuccessful",
            "transaction rejected",

            "رمز التحقق",
            "رمز التفعيل",
            "رمز الدخول",
            "verification code",
            "one time password",
            "otp",

            "عرض",
            "عروض",
            "promo",
            "promotion"
        ]

        // إذا احتوت الرسالة على إحدى عبارات التجاهل لا يتم حفظها
        for pattern in ignoredPatterns {
            if text.contains(pattern) {
                return false
            }
        }

        // كلمات وعبارات تدل على أن الرسالة عملية شراء
        let purchasePatterns = [
            "شراء إنترنت",
            "شراء انترنت",
            "شراء أونلاين",
            "شراء اونلاين",
            "شراء إلكتروني",
            "شراء الكتروني",
            "عملية شراء",
            "مشتريات",
            "نقطة بيع",
            "خصم من البطاقة",

            "purchase",
            "online purchase",
            "card purchase",
            "card payment",
            "payment",
            "paid",
            "pos",
            "e-commerce",
            "ecommerce"
        ]

        // إذا احتوت الرسالة على إحدى عبارات الشراء تعتبر عملية صحيحة
        for pattern in purchasePatterns {
            if text.contains(pattern) {
                return true
            }
        }

        // إذا لم نجد عبارة شراء يتم تجاهل الرسالة
        return false
    }

    // يستخرج مبلغ العملية من صيغ الرسائل المختلفة
    private func extractAmount(
        from message: String
    ) -> Double? {

        // يحذف أسطر الرصيد حتى لا يعتبر الرصيد مبلغ العملية
        let transactionText = removeBalanceLines(
            from: message
        )

        // صيغ العملات التي يمكن أن تظهر في رسالة البنك
        let currency =
            #"(?:SAR|S\.A\.R|SR|ر\.?\s?س\.?|ريال(?:\s+سعودي)?|﷼)"#

        // يدعم الأرقام الصحيحة والعشرية وفواصل الآلاف
        let number =
            #"([0-9]+(?:[., ][0-9]+)*)"#

        // صيغ المبالغ التي يمكن أن تظهر في رسالة البنك
        let patterns: [String] = [

            // مبلغ 75.50 SAR
            // مبلغ SAR 75.50
            #"(?i)(?:مبلغ|المبلغ|amount|total|قيمة|قيمة العملية|مبلغ العملية|transaction amount|purchase amount)\s*[:=\-]?\s*(?:"# +
                currency +
                #"\s*)?"# +
                number +
                #"(?:\s*"# +
                currency +
                #")?"#,

            // شراء بمبلغ 75.50 SAR
            // خصم بقيمة SAR 75.50
            #"(?i)(?:بمبلغ|بقيمة|بـ|شراء بمبلغ|شراء بقيمة|خصم بمبلغ|خصم بقيمة)\s*[:=\-]?\s*(?:"# +
                currency +
                #"\s*)?"# +
                number +
                #"(?:\s*"# +
                currency +
                #")?"#,

            // 2,300.80 SAR
            #"(?i)"# +
                number +
                #"\s*"# +
                currency,

            // SAR 2,300.80
            #"(?i)"# +
                currency +
                #"\s*"# +
                number
        ]

        // يجرب جميع صيغ المبالغ حتى يعثر على مبلغ صحيح
        for pattern in patterns {

            guard let regex = try? NSRegularExpression(
                pattern: pattern
            ) else {
                continue
            }

            guard let match = regex.firstMatch(
                in: transactionText,
                range: NSRange(
                    transactionText.startIndex...,
                    in: transactionText
                )
            ) else {
                continue
            }

            // يبحث داخل مجموعات Regex عن الرقم المستخرج
            for index in 1..<match.numberOfRanges {

                let resultRange = match.range(at: index)

                guard resultRange.location != NSNotFound,
                      let swiftRange = Range(
                        resultRange,
                        in: transactionText
                      ) else {
                    continue
                }

                let numberString = String(
                    transactionText[swiftRange]
                )

                // يحول النص المستخرج إلى مبلغ رقمي
                if let amount = parseNumber(numberString),
                   amount > 0 {
                    return amount
                }
            }
        }

        // لم يتم العثور على مبلغ صحيح
        return nil
    }

    // يحذف الأسطر التي تحتوي على الرصيد قبل البحث عن مبلغ العملية
    private func removeBalanceLines(
        from message: String
    ) -> String {

        // العبارات التي تدل على أن السطر يحتوي على الرصيد
        let balancePatterns = [
            "الرصيد المتاح",
            "الرصيد الحالي",
            "الرصيد بعد العملية",
            "رصيد الحساب",
            "رصيد البطاقة",
            "المبلغ المتبقي",
            "حد البطاقة المتاح",

            "available balance",
            "current balance",
            "remaining balance",
            "account balance",
            "card balance",
            "available limit",
            "credit limit"
        ]

        // يقسم الرسالة إلى أسطر ثم يحذف أسطر الرصيد
        return message
            .components(separatedBy: .newlines)
            .filter { line in

                let normalizedLine = line
                    .lowercased()
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

                return !balancePatterns.contains { pattern in
                    normalizedLine.contains(pattern)
                }
            }
            .joined(separator: "\n")
    }

    // يحول المبلغ النصي إلى Double مع دعم الفواصل المختلفة
    private func parseNumber(_ value: String) -> Double? {

        // يحذف المسافات العادية والخاصة من الرقم
        var number = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: "\u{202F}", with: "")

        let hasComma = number.contains(",")
        let hasDot = number.contains(".")

        // يعالج أرقامًا مثل 1,250.75 أو 1.250,75
        if hasComma && hasDot {

            guard let commaIndex = number.lastIndex(of: ","),
                  let dotIndex = number.lastIndex(of: ".") else {
                return nil
            }

            if commaIndex > dotIndex {

                // مثال: 1.250,75
                number = number.replacingOccurrences(
                    of: ".",
                    with: ""
                )

                number = number.replacingOccurrences(
                    of: ",",
                    with: "."
                )
            } else {

                // مثال: 1,250.75
                number = number.replacingOccurrences(
                    of: ",",
                    with: ""
                )
            }

            return Double(number)
        }

        // يعالج الأرقام التي تحتوي على فاصلة فقط
        if hasComma {

            let parts = number.split(separator: ",")

            if parts.count == 2 {

                let decimalPart = parts[1]

                if decimalPart.count == 1 ||
                    decimalPart.count == 2 {

                    // مثال: 100,50
                    number = number.replacingOccurrences(
                        of: ",",
                        with: "."
                    )
                } else {

                    // مثال: 1,250
                    number = number.replacingOccurrences(
                        of: ",",
                        with: ""
                    )
                }
            } else {

                // مثال: 1,250,000
                number = number.replacingOccurrences(
                    of: ",",
                    with: ""
                )
            }

            return Double(number)
        }

        // يعالج الأرقام التي تحتوي على نقطة فقط
        if hasDot {

            let parts = number.split(separator: ".")

            if parts.count == 2 {

                let decimalPart = parts[1]

                if decimalPart.count > 2 {

                    // مثال: 1.250
                    number = number.replacingOccurrences(
                        of: ".",
                        with: ""
                    )
                }
            } else if parts.count > 2 {

                // مثال: 1.250.000
                number = number.replacingOccurrences(
                    of: ".",
                    with: ""
                )
            }

            return Double(number)
        }

        // يحول الأرقام الصحيحة التي لا تحتوي على فواصل
        return Double(number)
    }

    // يحول الأرقام العربية والفواصل العربية إلى الصيغة الإنجليزية
    private func normalizeArabicNumbers(
        _ text: String
    ) -> String {

        let arabicNumbers = "٠١٢٣٤٥٦٧٨٩"
        let easternArabicNumbers = "۰۱۲۳۴۵۶۷۸۹"
        let englishNumbers = "0123456789"

        var result = ""

        // يمر على كل حرف ويحول الأرقام والرموز العربية
        for character in text {

            if let index = arabicNumbers.firstIndex(
                of: character
            ) {
                let offset = arabicNumbers.distance(
                    from: arabicNumbers.startIndex,
                    to: index
                )

                let englishIndex = englishNumbers.index(
                    englishNumbers.startIndex,
                    offsetBy: offset
                )

                result.append(
                    englishNumbers[englishIndex]
                )
            } else if let index =
                        easternArabicNumbers.firstIndex(
                            of: character
                        ) {
                let offset = easternArabicNumbers.distance(
                    from: easternArabicNumbers.startIndex,
                    to: index
                )

                let englishIndex = englishNumbers.index(
                    englishNumbers.startIndex,
                    offsetBy: offset
                )

                result.append(
                    englishNumbers[englishIndex]
                )
            } else if character == "٫" {

                // يحول الفاصل العشري العربي إلى نقطة
                result.append(".")
            } else if character == "٬" {

                // يحول فاصلة الآلاف العربية إلى فاصلة إنجليزية
                result.append(",")
            } else if character == "\u{00A0}" ||
                        character == "\u{202F}" {

                // يحول المسافات الخاصة إلى مسافة عادية
                result.append(" ")
            } else {
                result.append(character)
            }
        }

        return result
    }

    // يحاول استخراج اسم التاجر من صيغ الرسائل الشائعة مثل "من" أو "at"
    private func extractMerchantName(
        from message: String
    ) -> String? {

        let patterns = [

            // مثال: من Amazon أو لدى Zara أو at Apple
            #"(?i)(?:at|from|من|لدى)\s*[:\-]?\s*([^\r\n]+)"#,

            // مثال: التاجر: Amazon أو Merchant: Amazon
            #"(?i)(?:merchant|التاجر)\s*[:\-]?\s*([^\r\n]+)"#
        ]

        // يجرب صيغ اسم التاجر حتى يعثر على نتيجة
        for pattern in patterns {

            guard let regex = try? NSRegularExpression(
                pattern: pattern
            ) else {
                continue
            }

            guard let match = regex.firstMatch(
                in: message,
                range: NSRange(
                    message.startIndex...,
                    in: message
                )
            ) else {
                continue
            }

            guard match.numberOfRanges > 1,
                  let range = Range(
                    match.range(at: 1),
                    in: message
                  ) else {
                continue
            }

            // ينظف اسم التاجر من المسافات وعلامات الترقيم
            let merchant = String(message[range])
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .trimmingCharacters(
                    in: CharacterSet(
                        charactersIn: ".،,:;-"
                    )
                )

            // يرجع اسم التاجر إذا لم يكن فارغًا
            if !merchant.isEmpty {
                return merchant
            }
        }

        // لم يتم العثور على اسم التاجر
        return nil
    }
}
