import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/app_page_container.dart';
import '../components/card_container.dart';
import '../theme/app_colors.dart';

// 服務約定 from the About page: disclaimer, data sources, privacy, copyright
// and acknowledgements.
class ServiceTermsPage extends StatelessWidget {
  const ServiceTermsPage({super.key});

  static const TextStyle _headingStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.625);
  static const TextStyle _bodyStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.7);
  // Each level (一、 → （一） → 1.) is indented by the same visible step.
  static const double _indentStep = 16;
  // The full-width 「（」 is drawn in the right half of its box, so （一）
  // visibly starts about half a character (at 14px) right of its padding.
  // Level 2 adds this twice so 1. sits the same visible step past （.
  static const double _bracketInset = 7;
  // Width of the 1. column. （一） takes its own natural width instead: the
  // font renders it wider than 3 × 14px, so a fixed width wrapped it.
  static const double _level2NumberWidth = 20;
  static final TextStyle _highlightedStyle = _bodyStyle.copyWith(color: AppColors.primaryRed);

  static const List<_Block> _blocks = [
    _Heading('一、免責聲明'),
    _ListItem('（一）', '您於使用彰化基督教醫療財團法人彰化基督教兒童醫院（下稱本院）所開發之氣喘健康護照 APP（下稱本應用程式）時，本應用程式所提供或刊載之內容、資訊及問題答覆，僅以健康教育及衛教輔助為目的，不構成診斷、治療、處方或個別化醫療建議，亦不能取代醫師或其他合格醫療專業人員之專業判斷。', level: 1),
    _ListItem('（二）', '如您有任何個人健康或醫療相關疑問、疾病症狀、病情變化或身體不適，請諮詢合格醫療專業人員，必要時並應儘速就醫。此外，請勿僅依據本應用程式之內容，自行開始、停止或調整任何藥物，亦不應因此延誤就醫。', level: 1),
    _Heading('二、資料來源及人工智慧使用'),
    _ListItem('（一）', '本應用程式之過敏、氣喘相關健康教育與照護衛教內容，主要參考台灣兒童過敏氣喘免疫及風濕病醫學會、台灣氣喘暨過敏疾病衛教學會及台灣胸腔暨重症加護醫學會等專業學會所公開發表之資料，作為人工智慧（下稱AI）系統回覆之知識參考來源。', level: 1),
    _ListItem('（二）', '本應用程式之互動回覆由AI 系統生成，並非由真人醫療專業人員即時撰寫，亦非由上述學會或原著作權人製作或審查，不代表其認可、推薦或背書。AI 回覆可能有錯誤、遺漏或不符個別情境之情形，相關內容僅供參考，於作出任何健康相關決定前，請與醫療專業人員確認。', level: 1),
    _Heading('三、個人資料之蒐集與運用'),
    _ListItem('（一）', '本院依您使用本應用程式之功能及服務內容，蒐集提供服務所必要之個人資料，可能包括下列類別：', level: 1),
    _ListItem('1.', '個人識別資料：如姓名、出生日期、性別、手機號碼、電子郵件及其他足以識別個人之資料。'),
    _ListItem('2.', '就醫及健康資料：如就醫紀錄、醫療服務資訊。'),
    _ListItem('（二）', '本院僅於提供本應用程式服務、資訊安全維護及原蒐集目的之必要範圍內，依個人資料保護法及相關法令蒐集、處理及利用您的個人資料；非經法令規定或另行取得您的同意，不會作原蒐集目的外之利用。', level: 1),
    _ListItem('（三）', '本院蒐集之個人資料，將於原蒐集目的及法令許可範圍內，作為下列用途：', level: 1),
    _ListItem('1.', '提供、維護及優化本應用程式及相關服務。'),
    _ListItem('2.', '提供客服、系統維運、資訊安全管理、內部管理。'),
    _ListItem('3.', '依您的同意，提供健康資訊、衛教宣導及其他服務相關之通知。'),
    _ListItem('（四）', '資料安全及保留：', level: 1),
    _ListItem('1.', '本院採取適當之管理、技術及實體安全措施，保護您的個人資料，防止未經授權之存取、使用、洩漏、竄改、毀損或其他侵害，並定期檢視及更新相關安全措施。'),
    _ListItem('2.', '本院僅於原蒐集目的內，保存及利用您的個人資料；蒐集目的消失後，將刪除或停止使用。'),
    _ListItem('（五）', '本院原則上不會將您的個人資料提供、揭露予第三人。但有下列情形之一者，不在此限：', level: 1),
    _ListItem('1.', '已取得您的同意，或依法無須經您同意者。'),
    _ListItem('2.', '依法律規定，或應司法機關、主管機關等有權機關之要求者。'),
    _ListItem('3.', '為維護您或第三人之生命、身體、自由或財產安全所必要者。', highlighted: true),
    _ListItem('（六）', '您得依個人資料保護法，行使查詢、閱覽、製給複製本、補充、更正、停止蒐集、處理、利用及刪除等權利；如欲行使前述權利，請【聯絡管道】。', level: 1),
    _ListItem('（七）', '本院得因法令修正、服務內容調整或其他必要情形，適時修訂本隱私權規範；修訂後之內容將公布於本應用程式或相關網站，並自公布時生效，請您定期查閱，以保障您的權益。', level: 1),
    _Heading('四、著作權保護'),
    _ListItem('（一）', '本應用程式之軟體、商標、圖像、文字及其他內容，除另有規範外，其著作權及相關智慧財產權均屬本院所有，並受著作權法及相關法令保護。', level: 1),
    _ListItem('（二）', '本應用程式所參考或引用之專業資料，其著作權仍歸原著作權人所有。', level: 1),
    _ListItem('（三）', '就本應用程式自有內容，未經本院事前書面同意；就第三方專業資料，未經原著作權人事前書面同意，均不得以任何方式重製、改作、散布、公開傳輸，或為其他逾越合理使用範圍之利用。', level: 1),
    _Heading('五、致謝'),
    _Paragraph('本應用程式係由衛生福利部「健康台灣深耕計畫」補助開發，特此致謝。此外，亦感謝台灣兒童過敏氣喘免疫及風濕病醫學會、台灣氣喘暨過敏疾病衛教學會及台灣胸腔暨重症加護醫學會，長期致力於過敏、氣喘防治及照護所付出之努力與貢獻，其專業成果為臨床照護及病人衛教提供重要依據，使本應用程式得以提供更完善之內容。'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      contentPadding: EdgeInsets.zero,
      header: _buildHeader(context),
      content: CardContainer(
        borderRadius: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _blocks.map(_buildBlock).toList(),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          const Text(
            '致謝與資料來源聲明',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.0),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildBlock(_Block block) {
    return switch (block) {
      _Heading(:final text) => Text(text, style: _headingStyle),
      _Paragraph(:final text) => Padding(
          padding: const EdgeInsets.only(left: _indentStep),
          child: Text(text, style: _bodyStyle),
        ),
      // Number and text in separate columns, so wrapped lines align with the
      // text, not the number. Level 1 is （一）, level 2 is 1. under it.
      _ListItem(:final number, :final text, :final level, :final highlighted) => Padding(
          padding: EdgeInsets.only(left: level == 1 ? _indentStep : (_indentStep + _bracketInset) * 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (level == 1)
                Text(number, style: highlighted ? _highlightedStyle : _bodyStyle)
              else
                SizedBox(
                  width: _level2NumberWidth,
                  child: Text(number, style: highlighted ? _highlightedStyle : _bodyStyle),
                ),
              Expanded(child: Text(text, style: highlighted ? _highlightedStyle : _bodyStyle)),
            ],
          ),
        ),
    };
  }
}

sealed class _Block {
  final String text;
  const _Block(this.text);
}

class _Heading extends _Block {
  const _Heading(super.text);
}

class _Paragraph extends _Block {
  const _Paragraph(super.text);
}

class _ListItem extends _Block {
  final String number;
  final int level;
  final bool highlighted;
  const _ListItem(this.number, String text, {this.level = 2, this.highlighted = false}) : super(text);
}
