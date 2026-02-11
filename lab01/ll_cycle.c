#include <stddef.h>
#include "ll_cycle.h"

int ll_has_cycle(node *head) {
    if (head == NULL) {
        return 0;
    }
    node* p = head, *q = head;
    while (p != NULL && p->next != NULL) {
        p = p->next->next;
        q = q->next;
        if (p == q) {
            return 1;
        }
    }
    return 0;
}