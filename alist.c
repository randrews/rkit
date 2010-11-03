#include "rkit.h"

Node* alist_find(Node *head, const char *key);

/*************************************************/

void** alist_free(AList *alist){
	int length = alist_length(alist);
	void** values = malloc((length + 1) * sizeof(void*));
	values[length] = 0;

	int n = 0;
	Node *current = alist->head;
	while(current){
		values[n++] = current->value;
		free(current->key);
		Node *next = current->next;
		free(current);
		current = next;
	}

	return values;
}

int alist_length(AList *alist){
	int length = 0;
	Node *current = alist->head;

	while(current){
		length++;
		current = current->next;
	}

	return length;
}

void* alist_put(AList *alist, const char *key, void *value){
	Node *old_node = alist_find(alist->head, key);

	if(old_node){
		void *old_value = old_node->value;
		old_node->value = value;
		return old_value;
	} else {
		char *key_copy = strcpy(malloc(strlen(key)+1), key);
		Node *new_node = malloc(sizeof(Node));
		new_node->value = value;
		new_node->key = key_copy;
		new_node->next = 0;

		if(alist->last){
			alist->last->next = new_node;
			alist->last = new_node;
		} else {
			alist->last = alist->head = new_node;
		}

		return 0;
	}
}

void* alist_get(AList *list, const char *key){
	Node *node = alist_find(list->head, key);

	if(node){
		return node->value;
	} else {
		return 0;
	}
}

/*************************************************/

Node* alist_find(Node *head, const char *key){
	Node *current = head;

	while(current){
		if(strcmp(current->key, key) == 0){ return current; }
		current = current->next;
	}

	return 0;
}
