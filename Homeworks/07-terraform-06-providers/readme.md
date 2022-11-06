# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   

### Ответ

```markdown
Информация о resource и data_source находится в файле ./internal/provider/provider.go

**resource** -  ключи в map ResourcesMap: map[string]*schema.Resource
```

[https://github.com/hashicorp/terraform-provider-aws/blob/e1d68faa27997073d80bd71ae99f73a40a6ef20c/internal/provider/provider.go#L931](https://github.com/hashicorp/terraform-provider-aws/blob/e1d68faa27997073d80bd71ae99f73a40a6ef20c/internal/provider/provider.go#L931)

```markdown

**data_resource** - ключи в map DataSourcesMap: map[string]*schema.Resource

```
[https://github.com/hashicorp/terraform-provider-aws/blob/e1d68faa27997073d80bd71ae99f73a40a6ef20c/internal/provider/provider.go#L419](https://github.com/hashicorp/terraform-provider-aws/blob/e1d68faa27997073d80bd71ae99f73a40a6ef20c/internal/provider/provider.go#L419)



2. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
   
### Ответ 
```markdown
Конфликтует с `name_prefix`

Файл:
./internal/service/sqs/queue.go:

"name": {
			Type:          schema.TypeString,
			Optional:      true,
			Computed:      true,
			ForceNew:      true,
			ConflictsWith: []string{"name_prefix"},
		},

```


 * Какая максимальная длина имени? 
 * Какому регулярному выражению должно подчиняться имя? 

### Ответ 
```markdown
Максимальная длина имени 80 символов.

Согласно документации (./website/docs/r/sqs_queue.html.markdown):

name - (Optional) The name of the queue. 
Queue names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, 
and must be between 1 and 80 characters long. 
For a FIFO (first-in-first-out) queue, the name must end with the .fifo suffix. 

В реализации провайдера (файл: ./internal/service/sqs/queue.go) есть соответствующая проверка:

	if fifoQueue {
			re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,75}\.fifo$`)
		} else {
			re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,80}$`)
		}

		if !re.MatchString(name) {
			return fmt.Errorf("invalid queue name: %s", name)
		}
```
[https://github.com/hashicorp/terraform-provider-aws/blob/e1d68faa27997073d80bd71ae99f73a40a6ef20c/internal/service/sqs/queue.go#L413](https://github.com/hashicorp/terraform-provider-aws/blob/e1d68faa27997073d80bd71ae99f73a40a6ef20c/internal/service/sqs/queue.go#L413)
