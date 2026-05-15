import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class TermsBottomSheet extends StatefulWidget {
  final String title;
  final String checkboxText;
  final VoidCallback onConfirm;

  const TermsBottomSheet({
    super.key,
    required this.title,
    this.checkboxText = '本人已詳閱前述注意事項，並同意以上事項',
    required this.onConfirm,
  });

  @override
  State<TermsBottomSheet> createState() => _TermsBottomSheetState();
}

class _TermsBottomSheetState extends State<TermsBottomSheet> {
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    'assets/icons/close.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  ),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 24, height: 24),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.whiteMarble),
          // Scrollable content with checkbox
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                spacing: 12,
                children: [
                  Text(
                    '為保障合法使用「氣喘健康護照APP」（以下稱本APP）的權益，「本APP提供者」（以下稱提供者）訂定「會員條款」（以下稱本條款），敬請詳閱並遵守。使用本APP之服務者（不論是否加入會員），視為已閱讀、知悉並同意本條款。\n壹　會員權益\n註冊加入會員享有本APP之服務，相關權益、使用期限，以註冊為會員時之規定為準。\n貳　會員授權\n申請註冊加入會員，提供者有審核是否准允加入之權利。\n參　會員資料\n會員應填寫真實的資料，如資料有變更，應至「會員資料修改」功能進行修改，如因未修改而致權益受損，由會員自行負責。\n肆　會員密碼\n會員對於帳號、密碼應負保密之責，如未保密造成無法使用、資料被篡改及本APP之損失等情形，由會員自行承擔，並負損害賠償責任。\n伍　隱私權保護\n一　會員資料之保護\n本APP對於會員之資料，在未經會員同意前，不會任意將其透露、租借或轉售給第三人，並嚴禁內部人員私自利用。\n二　會員資料之處理\n（一）統計及分析\n提供者會記錄會員行為，但僅供作統計及分析之用，作為日後改善本APP內容及服務品質之依據。\n（二）活動及服務之通知\n提供者如舉辦任何活動，或增減、變更任何服務業務，將使用會員資料通知。\n三　資料保護之例外\n在下列幾種情況下，將會使用或透露會員資料：\n（一）司法機關或其他機關符合法定程序提出要求時。\n（二）經會員同意。\n（三）提供者於行銷或提供服務時。\n陸　使用規範\n一　一般聲明\n（一）本APP之資料係自各級政府機關蒐集而來，若與各主管機關公布之文字有所不同，仍以各主管機關公布之資料為準。\n（二）非經提供者正式書面同意，不得下載、重製本APP之內容他用。\n二　權利聲明\n（一）標的\n本APP之內容，包括（但不限於）本APP內所有之影像、圖片、動畫、視訊、音效、音樂、文字、資料以及全部應用程式...等。\n（二）權利保護\n本APP之著作權及其他權利，均受著作權法、公平交易法或其他法令，和國際著作權條約及其他相關法令與條約之保護。\n（三）使用權限\n本APP僅限於在電腦、手機、平板...等載具，利用本APP所提供之功能查詢、檢閱、下載或列印在紙上，但不包括以下權限：\n1. 將本APP之內容列印、存檔、下載、複製、剪貼，不論是否經過編輯，進一步利用於其他印刷物或電子媒體。但僅引用為論文、文件之內容或為該等文件附件之一部分，以作為說明者，不在此限。\n2. 將本APP之內容，重製於磁碟、光碟、硬碟、電子儲存媒體或其他載體，有償或無償提供自己或他人使用。\n3. 以程式或自動化方式執行查詢、下載、擷取內容…等方式，使用本APP。\n4. 將本APP之內容，載入自行或他人開發之系統中，充作資料庫之部分或全部。\n（四）使用授權\n1. 除非經提供者以正式書面同意，否則禁止對本APP所提供之資料重製、販售、出租、互易、出借、散布、出版、改作、改篡割裂、公開展示、公開傳輸及其他方式對外公佈其內容或為其他足以侵害提供者權益之行為。\n2. 使用者若有下載、重製、利用或其他使用授權之需求，請洽提供者。\n柒　終止服務\n會員若違反本條款或其他相關規定，提供者有權暫時停止或終止會員權利，前述情形，會員不得要求退還相關費用。如會員有事證證明未違規者，可向提供者提出要求重新處理。\n捌　修改會員條款之權利\n提供者得因應需要修正本條款之內容，並自公布之日起即時生效，將不對會員進行個別通知，請會員自行留意。',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.625,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => _isAgreed = !_isAgreed);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isAgreed ? AppColors.funGreen : Colors.black,
                              width: 2,
                            ),
                          ),
                          child: _isAgreed
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: SvgPicture.asset('assets/icons/check-fill.svg'),
                              )
                            : null,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.checkboxText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  CustomButton(
                    text: '確認',
                    onPressed: _isAgreed ? widget.onConfirm : () {},
                    backgroundColor: _isAgreed ? AppColors.funGreen : AppColors.richWhite,
                    height: 48,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
