#include "widget.h"
#include <QPushButton>
#include <QMessageBox>
 
Widget::Widget(QWidget *parent)
    : QWidget(parent)
{
    //创建一个PushButton
    QPushButton * btn = new QPushButton(tr("click me"),this);
    //连接信号和槽
    connect(btn,SIGNAL(clicked()),this,SLOT(btn_click()));
}
 
Widget::~Widget()
{
}
 
void Widget::btn_click()
{
    QMessageBox::information(NULL, tr("click button"),
                tr("hello world"), QMessageBox::Yes);
}

