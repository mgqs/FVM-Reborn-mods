@echo off
chcp 65001 >nul
cd /d "%~dp0\..\.."
echo ============================================
echo  本地 WebSocket 版授权机器人
echo ============================================
echo.
echo  [重要] 发码已经迁到腾讯云函数（Webhook）了。
echo         云端接管后，本地再开这个会跟云端抢同一条消息：
echo         玩家会收到两条一样的回复，账本会被写两次。
echo.
echo  只有云端挂掉、需要临时救急时才开。
echo  救完记得关掉窗口。
echo.
set /p ok="确实要启动本地 WS 版吗？输入 Y 回车继续："
if /i not "%ok%"=="Y" (
  echo.
  echo 已取消，未启动。
  pause >nul
  exit /b 0
)
echo.
set PYTHONIOENCODING=utf-8
python -u bots\qq_auth_bot\bot.py
echo.
echo 机器人已退出。按任意键关闭。
pause >nul
