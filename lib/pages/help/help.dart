import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildHelpSection(
          context,
          icon: Icons.login,
          title: '登录问题',
          children: [
            _buildHelpItem(
              '为什么登录后还是显示"未登录"? ',
              '请尝试点击右上角的刷新按钮刷新登录状态. 如果多次失败, 请检查网络(不要代理)/尝试登出后重新登录. 最终方案: 卸载重装.',
            ),
            _buildHelpItem(
              '账号密码是什么? ',
              '学校教务系统的账号密码. 如果忘记, 可以点击登录页面的"忘记密码"重置.',
            ),
          ],
        ),
        _buildHelpSection(
          context,
          icon: Icons.calendar_today,
          title: '课表说明',
          children: [
            _buildHelpItem(
              '如何切换周次? ',
              '在首页顶部的选项卡上左右滑动, 或者直接点击“第X周”即可切换. 默认会选择当前周.',
            ),
            _buildHelpItem(
              '数据多久更新一次? ',
              '每次重启/点击刷新按钮/登录都会从教务系统同步最新的课程数据并缓存至本地.',
            ),
          ],
        ),
        _buildHelpSection(
          context,
          icon: Icons.privacy_tip_outlined,
          title: '隐私与安全',
          children: [
            _buildHelpItem(
              '我的密码安全吗? ',
              '本应用仅在本地保存您的 Cookie, 不会上传您的密码到任何第三方服务器.',
            ),
            _buildHelpItem(
              '关于数据缓存',
              '应用会缓存最后一次成功获取的课表, 以便在离线状态下查看. 如需更新课表, 只需重启应用或点击刷新按钮即可.',
            ),
            _buildHelpItem(
              '实现原理是什么?',
              '通过webview伪装登录学校官网, 保存登录后的Cookie到本地. 携带此Cookie请求学校官网部分公开的API可获取部分数据(课表, 空教室); 通过截取业务ID获取成绩, 考试数据; 选课, 评教与请假因为没有测试条件, 故仅抓取了网站直链用作跳转.',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildContactCard(context),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHelpSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.hardEdge,
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: children,
      ),
    );
  }

  Widget _buildHelpItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q: $question',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'A: $answer',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('仍有疑问? ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            textAlign: .center,
            '如遇BUG或有功能建议, 请提Issue/PR或联系开发者',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.email_outlined),
            label: const Text('GitHub'),
          ),
        ],
      ),
    );
  }
}
